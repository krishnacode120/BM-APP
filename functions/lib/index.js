"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.testHooks = exports.setAdminRole = exports.setProductPrice = exports.updateInventoryStatus = exports.upsertCategory = exports.upsertProduct = exports.updateOrderFinancials = exports.updateAdminNote = exports.updatePaymentStatus = exports.updateOrderStatus = exports.createOrder = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
admin.initializeApp();
const db = admin.firestore();
const orderableStatuses = new Set(["available", "lowStock"]);
const orderStatuses = new Set([
    "pending",
    "confirmed",
    "processing",
    "ready",
    "outForDelivery",
    "delivered",
    "cancelled",
]);
const paymentStatuses = new Set([
    "pending",
    "verificationRequired",
    "verified",
    "failed",
    "refunded",
    "notRequired",
]);
const inventoryStatuses = new Set([
    "available",
    "lowStock",
    "outOfStock",
    "comingSoon",
    "hidden",
]);
const allowedOrderTransitions = new Map([
    ["pending", ["confirmed", "cancelled"]],
    ["confirmed", ["processing", "cancelled"]],
    ["processing", ["ready"]],
    ["ready", ["outForDelivery"]],
    ["outForDelivery", ["delivered"]],
    ["delivered", []],
    ["cancelled", []],
]);
exports.createOrder = (0, https_1.onCall)(async (request) => {
    const uid = request.auth?.uid;
    if (!uid)
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    const payload = parseRequest(request.data);
    const requestId = `${uid}_${payload.idempotencyKey}`;
    const now = admin.firestore.Timestamp.now();
    return db.runTransaction(async (tx) => {
        const requestRef = db.collection("orderRequests").doc(requestId);
        const requestDoc = await tx.get(requestRef);
        if (requestDoc.exists) {
            const orderId = requestDoc.get("orderId");
            if (!orderId)
                throw new https_1.HttpsError("aborted", "Order request is processing.");
            const existingOrder = await tx.get(db.collection("orders").doc(orderId));
            if (!existingOrder.exists)
                throw new https_1.HttpsError("not-found", "Order not found.");
            return { order: withId(existingOrder.id, existingOrder.data()) };
        }
        const locationDoc = await tx.get(db.collection("locations").doc(payload.locationId));
        if (!locationDoc.exists || locationDoc.get("active") !== true) {
            throw new https_1.HttpsError("failed-precondition", "Invalid delivery location.");
        }
        const itemSnapshots = [];
        let estimatedSubtotal = 0;
        for (const item of payload.items) {
            const productDoc = await tx.get(db.collection("products").doc(item.productId));
            if (!productDoc.exists || productDoc.get("isActive") !== true) {
                throw new https_1.HttpsError("failed-precondition", "Product unavailable.");
            }
            const product = productDoc.data();
            const stockStatus = product.stockStatus;
            if (!stockStatus || !orderableStatuses.has(stockStatus)) {
                throw new https_1.HttpsError("failed-precondition", "Product unavailable.");
            }
            const minQty = Number(product.minimumOrderQuantity ?? 1);
            if (item.quantity < minQty) {
                throw new https_1.HttpsError("invalid-argument", "Minimum order not met.");
            }
            const price = await currentPrice(tx, item.productId, payload.locationId, now);
            if (price == null) {
                throw new https_1.HttpsError("not-found", "Price unavailable.");
            }
            const subtotal = price * item.quantity;
            estimatedSubtotal += subtotal;
            itemSnapshots.push({
                productId: item.productId,
                productName: String(product.name ?? ""),
                productNameTamil: String(product.nameTamil ?? ""),
                imageUrl: product.thumbnail ?? null,
                unit: String(product.unit ?? "other"),
                quantity: item.quantity,
                priceAtOrder: price,
                subtotal,
                locationId: payload.locationId,
            });
        }
        const counterRef = db.collection("counters").doc("orders");
        const counterDoc = await tx.get(counterRef);
        const nextNumber = Number(counterDoc.get("next") ?? 10001);
        tx.set(counterRef, { next: nextNumber + 1 }, { merge: true });
        const orderRef = db.collection("orders").doc();
        const location = locationDoc.data();
        const order = {
            orderNumber: `BM${nextNumber}`,
            userId: uid,
            customerName: payload.customerName,
            phoneNumber: payload.phoneNumber,
            deliveryAddress: payload.deliveryAddress ?? "",
            locationId: payload.locationId,
            locationName: `${location.city ?? ""}, ${location.state ?? ""}`.trim(),
            locationSnapshot: {
                locationId: payload.locationId,
                city: location.city ?? "",
                district: location.district ?? "",
                state: location.state ?? "",
                country: location.country ?? "India",
            },
            items: itemSnapshots,
            estimatedSubtotal,
            orderStatus: "pending",
            paymentStatus: "pending",
            customerNote: payload.customerNote ?? null,
            adminNote: null,
            createdAt: now,
            updatedAt: now,
        };
        tx.create(orderRef, order);
        tx.create(requestRef, {
            userId: uid,
            idempotencyKey: payload.idempotencyKey,
            orderId: orderRef.id,
            createdAt: now,
        });
        return { order: withId(orderRef.id, order) };
    });
});
exports.updateOrderStatus = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const orderId = readId(request.data, "orderId");
    const nextStatus = String(request.data?.status ?? "").trim();
    if (!orderStatuses.has(nextStatus)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid order status.");
    }
    return updateOrderFields(adminUid, orderId, "ORDER_STATUS_CHANGED", (current) => {
        const previous = String(current.orderStatus ?? "pending");
        if (!canTransition(previous, nextStatus)) {
            throw new https_1.HttpsError("failed-precondition", "Invalid order status transition.");
        }
        return {
            updates: {
                orderStatus: nextStatus,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                [`${nextStatus}At`]: admin.firestore.FieldValue.serverTimestamp(),
                [`${nextStatus}By`]: adminUid,
            },
            oldValue: { orderStatus: previous },
            newValue: { orderStatus: nextStatus },
        };
    });
});
exports.updatePaymentStatus = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const orderId = readId(request.data, "orderId");
    const paymentStatus = String(request.data?.paymentStatus ?? "").trim();
    if (!paymentStatuses.has(paymentStatus)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid payment status.");
    }
    return updateOrderFields(adminUid, orderId, "PAYMENT_STATUS_CHANGED", (current) => ({
        updates: {
            paymentStatus,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            ...(paymentStatus === "verified" ? {
                paymentVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
                paymentVerifiedBy: adminUid,
            } : {}),
        },
        oldValue: { paymentStatus: current.paymentStatus ?? null },
        newValue: { paymentStatus },
    }));
});
exports.updateAdminNote = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const orderId = readId(request.data, "orderId");
    const note = String(request.data?.adminNote ?? "").trim();
    if (note.length > 1000)
        throw new https_1.HttpsError("invalid-argument", "Admin note is too long.");
    return updateOrderFields(adminUid, orderId, "ADMIN_NOTE_UPDATED", (current) => ({
        updates: {
            adminNote: note,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            adminNoteUpdatedBy: adminUid,
        },
        oldValue: { adminNote: current.adminNote ?? null },
        newValue: { adminNote: note },
    }));
});
exports.updateOrderFinancials = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const orderId = readId(request.data, "orderId");
    const data = request.data;
    const confirmedSubtotal = readOptionalMoney(data.confirmedSubtotal);
    const deliveryCharge = readOptionalMoney(data.deliveryCharge) ?? 0;
    if (confirmedSubtotal == null) {
        throw new https_1.HttpsError("invalid-argument", "Confirmed subtotal is required.");
    }
    return updateOrderFields(adminUid, orderId, "ORDER_TOTAL_CONFIRMED", (current) => ({
        updates: {
            confirmedSubtotal,
            deliveryCharge,
            finalTotal: confirmedSubtotal + deliveryCharge,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            financialsUpdatedBy: adminUid,
        },
        oldValue: {
            confirmedSubtotal: current.confirmedSubtotal ?? null,
            deliveryCharge: current.deliveryCharge ?? null,
            finalTotal: current.finalTotal ?? null,
        },
        newValue: { confirmedSubtotal, deliveryCharge, finalTotal: confirmedSubtotal + deliveryCharge },
    }));
});
exports.upsertProduct = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const data = request.data;
    const id = String(data.id ?? "").trim() || db.collection("products").doc().id;
    const product = parseProduct(data);
    const ref = db.collection("products").doc(id);
    const before = await ref.get();
    await ref.set({
        ...product,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: adminUid,
        ...(before.exists ? {} : {
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: adminUid,
        }),
    }, { merge: true });
    await writeAudit(adminUid, before.exists ? "PRODUCT_UPDATED" : "PRODUCT_CREATED", "product", id, before.data() ?? null, product);
    return { id };
});
exports.upsertCategory = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const data = request.data;
    const id = String(data.id ?? "").trim() || db.collection("categories").doc().id;
    const category = parseCategory(data);
    const ref = db.collection("categories").doc(id);
    const before = await ref.get();
    await ref.set({
        ...category,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: adminUid,
        ...(before.exists ? {} : {
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: adminUid,
        }),
    }, { merge: true });
    await writeAudit(adminUid, before.exists ? "CATEGORY_UPDATED" : "CATEGORY_CREATED", "category", id, before.data() ?? null, category);
    return { id };
});
exports.updateInventoryStatus = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const productId = readId(request.data, "productId");
    const status = String(request.data?.stockStatus ?? "").trim();
    if (!inventoryStatuses.has(status)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid inventory status.");
    }
    const stockQuantity = readOptionalInteger(request.data?.stockQuantity);
    const ref = db.collection("products").doc(productId);
    const before = await ref.get();
    if (!before.exists)
        throw new https_1.HttpsError("not-found", "Product not found.");
    const updates = {
        stockStatus: status,
        ...(stockQuantity == null ? {} : { stockQuantity }),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: adminUid,
    };
    await ref.update(updates);
    await writeAudit(adminUid, "INVENTORY_CHANGED", "product", productId, { stockStatus: before.get("stockStatus"), stockQuantity: before.get("stockQuantity") ?? null }, { stockStatus: status, stockQuantity });
    return { id: productId };
});
exports.setProductPrice = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const data = request.data;
    const productId = readId(data, "productId");
    const locationId = readId(data, "locationId");
    const price = readMoney(data.price);
    const now = admin.firestore.Timestamp.now();
    await db.runTransaction(async (tx) => {
        const product = await tx.get(db.collection("products").doc(productId));
        const location = await tx.get(db.collection("locations").doc(locationId));
        if (!product.exists)
            throw new https_1.HttpsError("not-found", "Product not found.");
        if (!location.exists || location.get("active") !== true) {
            throw new https_1.HttpsError("not-found", "Location not found.");
        }
        const activePrices = await tx.get(db.collection("productPrices")
            .where("productId", "==", productId)
            .where("locationId", "==", locationId)
            .where("effectiveTo", "==", null)
            .limit(10));
        let oldValue = null;
        for (const doc of activePrices.docs) {
            oldValue = doc.data();
            tx.update(doc.ref, {
                effectiveTo: now,
                updatedAt: now,
                updatedBy: adminUid,
            });
        }
        const priceRef = db.collection("productPrices").doc();
        tx.create(priceRef, {
            productId,
            locationId,
            price,
            effectiveFrom: now,
            effectiveTo: null,
            updatedAt: now,
            updatedBy: adminUid,
        });
        tx.create(db.collection("auditLogs").doc(), auditData(adminUid, "PRICE_CHANGED", "productPrice", priceRef.id, oldValue, { productId, locationId, price }));
    });
    return { productId, locationId, price };
});
exports.setAdminRole = (0, https_1.onCall)(async (request) => {
    const adminUid = requireAdmin(request.auth);
    const data = request.data;
    const targetUid = readId(data, "targetUid");
    if (targetUid === adminUid && data.enabled === false) {
        throw new https_1.HttpsError("failed-precondition", "Admins cannot revoke themselves.");
    }
    const enabled = data.enabled !== false;
    await admin.auth().setCustomUserClaims(targetUid, enabled ? { role: "admin", admin: true } : { role: "user", admin: false });
    await db.collection("users").doc(targetUid).set({
        role: enabled ? "admin" : "user",
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedBy: adminUid,
    }, { merge: true });
    await writeAudit(adminUid, enabled ? "ADMIN_CREATED" : "ADMIN_REVOKED", "user", targetUid, null, { role: enabled ? "admin" : "user" });
    return { targetUid, role: enabled ? "admin" : "user" };
});
function parseRequest(data) {
    if (!data || typeof data !== "object") {
        throw new https_1.HttpsError("invalid-argument", "Invalid request.");
    }
    const value = data;
    const items = value.items;
    if (!Array.isArray(items) || items.length === 0 || items.length > 50) {
        throw new https_1.HttpsError("invalid-argument", "Invalid items.");
    }
    const parsedItems = items.map((raw) => {
        const item = raw;
        const productId = String(item.productId ?? "").trim();
        const quantity = Number(item.quantity);
        if (!productId || !Number.isInteger(quantity) || quantity < 1 || quantity > 1000000) {
            throw new https_1.HttpsError("invalid-argument", "Invalid item.");
        }
        return { productId, quantity };
    });
    const request = {
        idempotencyKey: String(value.idempotencyKey ?? "").trim(),
        locationId: String(value.locationId ?? "").trim(),
        customerName: String(value.customerName ?? "").trim(),
        phoneNumber: String(value.phoneNumber ?? "").trim(),
        deliveryAddress: String(value.deliveryAddress ?? "").trim(),
        customerNote: String(value.customerNote ?? "").trim(),
        items: parsedItems,
    };
    if (!/^[A-Za-z0-9_-]{16,80}$/.test(request.idempotencyKey) ||
        !request.locationId ||
        !request.customerName ||
        request.phoneNumber.length < 8 ||
        (request.customerNote?.length ?? 0) > 500) {
        throw new https_1.HttpsError("invalid-argument", "Invalid order details.");
    }
    return request;
}
function requireAdmin(auth) {
    if (!auth?.uid)
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    if (auth.token.admin !== true && auth.token.role !== "admin") {
        throw new https_1.HttpsError("permission-denied", "Admin access required.");
    }
    return auth.uid;
}
function readId(data, field) {
    const value = String(data?.[field] ?? "").trim();
    if (!/^[A-Za-z0-9_-]{1,128}$/.test(value)) {
        throw new https_1.HttpsError("invalid-argument", `Invalid ${field}.`);
    }
    return value;
}
function readMoney(value) {
    const amount = Number(value);
    if (!Number.isFinite(amount) || amount < 0) {
        throw new https_1.HttpsError("invalid-argument", "Invalid amount.");
    }
    return amount;
}
function readOptionalMoney(value) {
    if (value == null || value === "")
        return null;
    return readMoney(value);
}
function readOptionalInteger(value) {
    if (value == null || value === "")
        return null;
    const parsed = Number(value);
    if (!Number.isInteger(parsed) || parsed < 0) {
        throw new https_1.HttpsError("invalid-argument", "Invalid quantity.");
    }
    return parsed;
}
function canTransition(from, to) {
    return allowedOrderTransitions.get(from)?.includes(to) ?? false;
}
async function updateOrderFields(adminUid, orderId, action, build) {
    const ref = db.collection("orders").doc(orderId);
    return db.runTransaction(async (tx) => {
        const doc = await tx.get(ref);
        if (!doc.exists)
            throw new https_1.HttpsError("not-found", "Order not found.");
        const change = build(doc.data());
        tx.update(ref, change.updates);
        tx.create(db.collection("auditLogs").doc(), auditData(adminUid, action, "order", orderId, change.oldValue, change.newValue));
        const after = { ...doc.data(), ...change.updates, id: orderId };
        return { order: after };
    });
}
function parseProduct(data) {
    const name = String(data.name ?? "").trim();
    const categoryId = String(data.categoryId ?? "").trim();
    const unit = String(data.unit ?? "").trim();
    const stockStatus = String(data.stockStatus ?? "available").trim();
    const minimumOrderQuantity = Number(data.minimumOrderQuantity ?? 1);
    if (!name || !categoryId || !unit || !inventoryStatuses.has(stockStatus) ||
        !Number.isInteger(minimumOrderQuantity) || minimumOrderQuantity < 1) {
        throw new https_1.HttpsError("invalid-argument", "Invalid product.");
    }
    return {
        name,
        nameTamil: String(data.nameTamil ?? "").trim(),
        categoryId,
        description: String(data.description ?? "").trim(),
        descriptionTamil: String(data.descriptionTamil ?? "").trim(),
        brand: String(data.brand ?? "").trim(),
        unit,
        minimumOrderQuantity,
        stockStatus,
        stockQuantity: readOptionalInteger(data.stockQuantity),
        specifications: readObject(data.specifications),
        keywords: readStringArray(data.keywords),
        images: readStringArray(data.images),
        thumbnail: String(data.thumbnail ?? "").trim() || null,
        isPopular: data.isPopular === true,
        isFeatured: data.isFeatured === true,
        isActive: data.isActive !== false,
    };
}
function parseCategory(data) {
    const name = String(data.name ?? "").trim();
    const sortOrder = Number(data.sortOrder ?? 0);
    if (!name || !Number.isInteger(sortOrder)) {
        throw new https_1.HttpsError("invalid-argument", "Invalid category.");
    }
    return {
        name,
        nameTamil: String(data.nameTamil ?? "").trim(),
        description: String(data.description ?? "").trim(),
        descriptionTamil: String(data.descriptionTamil ?? "").trim(),
        imageUrl: String(data.imageUrl ?? "").trim() || null,
        sortOrder,
        isActive: data.isActive !== false,
    };
}
function readStringArray(value) {
    if (!Array.isArray(value))
        return [];
    return value.map((item) => String(item).trim()).filter(Boolean).slice(0, 50);
}
function readObject(value) {
    if (!value || typeof value !== "object" || Array.isArray(value))
        return {};
    return Object.fromEntries(Object.entries(value)
        .map(([key, val]) => [key, String(val)]));
}
async function currentPrice(tx, productId, locationId, now) {
    const snapshot = await tx.get(db.collection("productPrices")
        .where("productId", "==", productId)
        .where("locationId", "==", locationId)
        .orderBy("effectiveFrom", "desc")
        .limit(5));
    for (const doc of snapshot.docs) {
        const data = doc.data();
        const effectiveFrom = data.effectiveFrom;
        const effectiveTo = data.effectiveTo;
        if ((!effectiveFrom || effectiveFrom.toMillis() <= now.toMillis()) &&
            (!effectiveTo || effectiveTo.toMillis() > now.toMillis())) {
            return Number(data.price);
        }
    }
    return null;
}
function withId(id, data) {
    return { ...data, id };
}
function auditData(actorUserId, action, entityType, entityId, oldValue, newValue) {
    return {
        actorUserId,
        actorRole: "admin",
        action,
        entityType,
        entityId,
        oldValue,
        newValue,
        metadata: {},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };
}
async function writeAudit(actorUserId, action, entityType, entityId, oldValue, newValue) {
    await db.collection("auditLogs").add(auditData(actorUserId, action, entityType, entityId, oldValue, newValue));
}
exports.testHooks = { canTransition };
//# sourceMappingURL=index.js.map