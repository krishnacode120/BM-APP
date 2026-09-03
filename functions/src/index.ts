import * as admin from "firebase-admin";
import {HttpsError, onCall} from "firebase-functions/v2/https";

admin.initializeApp();
const db = admin.firestore();

type OrderRequestItem = {
  productId: string;
  quantity: number;
};

type CreateOrderRequest = {
  idempotencyKey: string;
  locationId: string;
  customerName: string;
  phoneNumber: string;
  deliveryAddress?: string;
  customerNote?: string;
  items: OrderRequestItem[];
};

const orderableStatuses = new Set(["available", "lowStock"]);

export const createOrder = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");
  const payload = parseRequest(request.data);
  const requestId = `${uid}_${payload.idempotencyKey}`;
  const now = admin.firestore.Timestamp.now();

  return db.runTransaction(async (tx) => {
    const requestRef = db.collection("orderRequests").doc(requestId);
    const requestDoc = await tx.get(requestRef);
    if (requestDoc.exists) {
      const orderId = requestDoc.get("orderId") as string | undefined;
      if (!orderId) throw new HttpsError("aborted", "Order request is processing.");
      const existingOrder = await tx.get(db.collection("orders").doc(orderId));
      if (!existingOrder.exists) throw new HttpsError("not-found", "Order not found.");
      return {order: withId(existingOrder.id, existingOrder.data()!)};
    }

    const locationDoc = await tx.get(db.collection("locations").doc(payload.locationId));
    if (!locationDoc.exists || locationDoc.get("active") !== true) {
      throw new HttpsError("failed-precondition", "Invalid delivery location.");
    }

    const itemSnapshots = [];
    let estimatedSubtotal = 0;
    for (const item of payload.items) {
      const productDoc = await tx.get(db.collection("products").doc(item.productId));
      if (!productDoc.exists || productDoc.get("isActive") !== true) {
        throw new HttpsError("failed-precondition", "Product unavailable.");
      }
      const product = productDoc.data()!;
      const stockStatus = product.stockStatus as string | undefined;
      if (!stockStatus || !orderableStatuses.has(stockStatus)) {
        throw new HttpsError("failed-precondition", "Product unavailable.");
      }
      const minQty = Number(product.minimumOrderQuantity ?? 1);
      if (item.quantity < minQty) {
        throw new HttpsError("invalid-argument", "Minimum order not met.");
      }
      const price = await currentPrice(tx, item.productId, payload.locationId, now);
      if (price == null) {
        throw new HttpsError("not-found", "Price unavailable.");
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
    tx.set(counterRef, {next: nextNumber + 1}, {merge: true});

    const orderRef = db.collection("orders").doc();
    const location = locationDoc.data()!;
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
    return {order: withId(orderRef.id, order)};
  });
});

function parseRequest(data: unknown): CreateOrderRequest {
  if (!data || typeof data !== "object") {
    throw new HttpsError("invalid-argument", "Invalid request.");
  }
  const value = data as Record<string, unknown>;
  const items = value.items;
  if (!Array.isArray(items) || items.length === 0 || items.length > 50) {
    throw new HttpsError("invalid-argument", "Invalid items.");
  }
  const parsedItems = items.map((raw) => {
    const item = raw as Record<string, unknown>;
    const productId = String(item.productId ?? "").trim();
    const quantity = Number(item.quantity);
    if (!productId || !Number.isInteger(quantity) || quantity < 1 || quantity > 1000000) {
      throw new HttpsError("invalid-argument", "Invalid item.");
    }
    return {productId, quantity};
  });
  const request: CreateOrderRequest = {
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
    throw new HttpsError("invalid-argument", "Invalid order details.");
  }
  return request;
}

async function currentPrice(
  tx: admin.firestore.Transaction,
  productId: string,
  locationId: string,
  now: admin.firestore.Timestamp
): Promise<number | null> {
  const snapshot = await tx.get(db.collection("productPrices")
    .where("productId", "==", productId)
    .where("locationId", "==", locationId)
    .orderBy("effectiveFrom", "desc")
    .limit(5));
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const effectiveFrom = data.effectiveFrom as admin.firestore.Timestamp | undefined;
    const effectiveTo = data.effectiveTo as admin.firestore.Timestamp | undefined;
    if ((!effectiveFrom || effectiveFrom.toMillis() <= now.toMillis()) &&
        (!effectiveTo || effectiveTo.toMillis() > now.toMillis())) {
      return Number(data.price);
    }
  }
  return null;
}

function withId(id: string, data: admin.firestore.DocumentData) {
  return {...data, id};
}
