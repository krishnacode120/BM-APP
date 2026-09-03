import * as admin from "firebase-admin";

export type NotificationEvent =
  | "ORDER_CREATED"
  | "ORDER_CONFIRMED"
  | "ORDER_PROCESSING"
  | "ORDER_READY"
  | "ORDER_OUT_FOR_DELIVERY"
  | "ORDER_DELIVERED"
  | "ORDER_CANCELLED"
  | "PAYMENT_VERIFIED"
  | "NEW_ORDER"
  | "LOW_STOCK";

export type ReportEvent =
  | "ORDER_CREATED"
  | "ORDER_STATUS_CHANGED"
  | "PAYMENT_STATUS_CHANGED"
  | "ORDER_FINANCIALS_CHANGED";

type JobRecord = admin.firestore.DocumentData & {
  type: string;
  entityId: string;
  status: string;
  attemptCount: number;
  nextRetryAt?: admin.firestore.Timestamp;
  leaseExpiresAt?: admin.firestore.Timestamp;
};

type DeviceRecord = {
  path: string;
  token: string;
  locale: string;
};

type GraphConfig = {
  tenantId: string;
  clientId: string;
  clientSecret: string;
  driveId: string;
  workbookItemId: string;
  ordersTable: string;
  orderItemsTable: string;
};

const maxAttempts = 5;
const retryDelaysMinutes = [1, 5, 30, 120];

export function enqueueOrderNotification(
  tx: admin.firestore.Transaction,
  db: admin.firestore.Firestore,
  order: admin.firestore.DocumentData & {id: string},
  event: NotificationEvent,
  now: admin.firestore.Timestamp,
): void {
  const recipientKind = event === "NEW_ORDER" || event === "LOW_STOCK"
    ? "admin"
    : "customer";
  const recipientUserId = recipientKind === "customer" ? String(order.userId) : null;
  const jobId = `${order.id}_${event}_${recipientKind}`;
  tx.set(db.collection("notificationJobs").doc(jobId), {
    type: event,
    entityType: "order",
    entityId: order.id,
    orderNumber: String(order.orderNumber ?? ""),
    recipientKind,
    recipientUserId,
    route: recipientKind === "admin" ? `/admin/orders/${order.id}` : `/orders/${order.id}`,
    status: "PENDING",
    attemptCount: 0,
    nextRetryAt: now,
    createdAt: now,
    updatedAt: now,
  }, {merge: true});
}

export function enqueueOrderReportSync(
  tx: admin.firestore.Transaction,
  db: admin.firestore.Firestore,
  orderId: string,
  event: ReportEvent,
  now: admin.firestore.Timestamp,
  orderNumber?: string,
): void {
  tx.set(db.collection("reportSyncJobs").doc(orderId), {
    type: event,
    entityType: "order",
    entityId: orderId,
    ...(orderNumber == null ? {} : {orderNumber}),
    status: "PENDING",
    attemptCount: 0,
    nextRetryAt: now,
    lastError: null,
    completedAt: null,
    updatedAt: now,
    createdAt: now,
  }, {merge: true});
}

export function enqueueLowStockNotification(
  batch: admin.firestore.WriteBatch,
  db: admin.firestore.Firestore,
  productId: string,
  productName: string,
): void {
  const now = admin.firestore.Timestamp.now();
  batch.set(db.collection("notificationJobs").doc(`${productId}_LOW_STOCK_admin`), {
    type: "LOW_STOCK",
    entityType: "product",
    entityId: productId,
    productName,
    recipientKind: "admin",
    recipientUserId: null,
    route: "/admin",
    status: "PENDING",
    attemptCount: 0,
    nextRetryAt: now,
    createdAt: now,
    updatedAt: now,
  }, {merge: true});
}

export function notificationEventForStatus(status: string): NotificationEvent | null {
  const mapped: Record<string, NotificationEvent> = {
    confirmed: "ORDER_CONFIRMED",
    processing: "ORDER_PROCESSING",
    ready: "ORDER_READY",
    outForDelivery: "ORDER_OUT_FOR_DELIVERY",
    delivered: "ORDER_DELIVERED",
    cancelled: "ORDER_CANCELLED",
  };
  return mapped[status] ?? null;
}

export function notificationTemplate(
  type: NotificationEvent,
  locale: string,
  orderNumber: string,
  productName = "",
): {title: string; body: string} {
  const tamil = locale.toLowerCase().startsWith("ta");
  const customer: Record<Exclude<NotificationEvent, "NEW_ORDER" | "LOW_STOCK">, [string, string, string, string]> = {
    ORDER_CREATED: ["Order Submitted", "{order} has been received.", "ஆர்டர் சமர்ப்பிக்கப்பட்டது", "{order} பெறப்பட்டது."],
    ORDER_CONFIRMED: ["Order Confirmed", "{order} has been confirmed.", "ஆர்டர் உறுதிப்படுத்தப்பட்டது", "{order} உறுதிப்படுத்தப்பட்டது."],
    ORDER_PROCESSING: ["Order Processing", "{order} is being prepared.", "ஆர்டர் செயல்பாட்டில்", "{order} தயாராகிறது."],
    ORDER_READY: ["Ready for Delivery", "{order} is ready for delivery.", "விநியோகத்திற்கு தயார்", "{order} விநியோகத்திற்கு தயாராக உள்ளது."],
    ORDER_OUT_FOR_DELIVERY: ["Out for Delivery", "{order} is on the way.", "விநியோகத்திற்கு புறப்பட்டது", "{order} வழியில் உள்ளது."],
    ORDER_DELIVERED: ["Order Delivered", "{order} has been delivered.", "ஆர்டர் வழங்கப்பட்டது", "{order} வழங்கப்பட்டது."],
    ORDER_CANCELLED: ["Order Cancelled", "{order} has been cancelled.", "ஆர்டர் ரத்து செய்யப்பட்டது", "{order} ரத்து செய்யப்பட்டது."],
    PAYMENT_VERIFIED: ["Payment Verified", "Payment for {order} has been verified.", "பணம் சரிபார்க்கப்பட்டது", "{order} க்கான பணம் சரிபார்க்கப்பட்டது."],
  };
  if (type === "NEW_ORDER") {
    return {title: "New BM Order", body: `${orderNumber} — new customer order`};
  }
  if (type === "LOW_STOCK") {
    return {title: "Low stock", body: `${productName || "A product"} needs attention`};
  }
  const copy = customer[type];
  return {
    title: (tamil ? copy[2] : copy[0]),
    body: (tamil ? copy[3] : copy[1]).replace("{order}", orderNumber),
  };
}

export function retryDecision(attemptCount: number, failureCode: string): {
  status: "RETRYING" | "DEAD_LETTER" | "FAILED";
  delayMinutes?: number;
} {
  if (failureCode === "CONFIGURATION_REQUIRED" || failureCode === "ORDER_NOT_FOUND" ||
      failureCode === "PERMANENT") return {status: "FAILED"};
  if (attemptCount >= maxAttempts) return {status: "DEAD_LETTER"};
  return {status: "RETRYING", delayMinutes: retryDelaysMinutes[Math.min(attemptCount - 1, retryDelaysMinutes.length - 1)]};
}

export function isTransientFailure(error: unknown): boolean {
  const code = String((error as {code?: unknown})?.code ?? "");
  const status = Number((error as {status?: unknown})?.status ?? 0);
  return status === 429 || status >= 500 || [
    "messaging/internal-error",
    "messaging/server-unavailable",
    "messaging/quota-exceeded",
    "messaging/unknown-error",
  ].includes(code);
}

export function dedupeDevices(devices: DeviceRecord[]): DeviceRecord[] {
  const seen = new Set<string>();
  return devices.filter((device) => {
    if (!device.token || seen.has(device.token)) return false;
    seen.add(device.token);
    return true;
  });
}

export async function processNotificationJob(
  db: admin.firestore.Firestore,
  jobId: string,
): Promise<void> {
  const claimed = await claimJob(db, "notificationJobs", jobId);
  if (!claimed) return;
  const {job, attemptCount} = claimed;
  try {
    const devices = await resolveDevices(db, job);
    if (devices.length === 0) {
      await completeNotification(db, jobId, attemptCount, "NO_ACTIVE_TOKENS");
      return;
    }
    const byLocale = new Map<string, DeviceRecord[]>();
    for (const device of devices) {
      const key = job.recipientKind === "admin" ? "en" : device.locale;
      byLocale.set(key, [...(byLocale.get(key) ?? []), device]);
    }
    const retryPaths: string[] = [];
    const invalidPaths: string[] = [];
    let sentCount = 0;
    for (const [locale, group] of byLocale) {
      const message = notificationTemplate(job.type as NotificationEvent, locale,
        String(job.orderNumber ?? ""), String(job.productName ?? ""));
      const result = await admin.messaging().sendEachForMulticast({
        tokens: group.map((device) => device.token),
        notification: message,
        data: {
          type: String(job.type),
          entityId: String(job.entityId),
          orderId: String(job.entityType === "order" ? job.entityId : ""),
          orderNumber: String(job.orderNumber ?? ""),
          route: String(job.route ?? "/home"),
        },
        android: {notification: {channelId: "bm_order_updates", sound: "default"}},
        apns: {payload: {aps: {sound: "default"}}},
      });
      result.responses.forEach((response, index) => {
        if (response.success) {
          sentCount += 1;
          return;
        }
        const code = String(response.error?.code ?? "");
        if (code === "messaging/registration-token-not-registered" ||
            code === "messaging/invalid-registration-token") {
          invalidPaths.push(group[index].path);
        } else if (isTransientFailure(response.error)) {
          retryPaths.push(group[index].path);
        }
      });
    }
    await Promise.all(invalidPaths.map((path) => db.doc(path).set({
      enabled: false,
      invalidatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true})));
    if (retryPaths.length > 0) {
      await retryNotification(db, jobId, attemptCount, retryPaths, "TRANSIENT_FCM_FAILURE");
      return;
    }
    await completeNotification(db, jobId, attemptCount, sentCount > 0 ? "SENT" : "NO_VALID_TOKENS");
  } catch (error) {
    await retryNotification(db, jobId, attemptCount, [], isTransientFailure(error) ? "TRANSIENT_FCM_FAILURE" : "PERMANENT");
  }
}

export async function processReportSyncJob(
  db: admin.firestore.Firestore,
  jobId: string,
  config: GraphConfig,
): Promise<void> {
  const claimed = await claimJob(db, "reportSyncJobs", jobId);
  if (!claimed) return;
  const {job, attemptCount} = claimed;
  const orderDoc = await db.collection("orders").doc(String(job.entityId)).get();
  if (!orderDoc.exists) {
    await finishReportFailure(db, jobId, attemptCount, "ORDER_NOT_FOUND");
    return;
  }
  try {
    if (!isGraphConfigured(config)) throw new ReportingError("CONFIGURATION_REQUIRED");
    await new MicrosoftGraphReportingService(config).upsertOrder({id: orderDoc.id, ...orderDoc.data()!});
    const now = admin.firestore.Timestamp.now();
    await Promise.all([
      db.collection("reportSyncJobs").doc(jobId).set({
        status: "COMPLETED", completedAt: now, updatedAt: now, lastError: null,
        leaseExpiresAt: null,
      }, {merge: true}),
      db.collection("reportSyncState").doc(String(job.entityId)).set({
        orderId: String(job.entityId), status: "SYNCED", syncedAt: now, updatedAt: now,
        lastError: null,
      }, {merge: true}),
    ]);
  } catch (error) {
    const code = error instanceof ReportingError ? error.code :
      isTransientFailure(error) ? "TRANSIENT" : "PERMANENT";
    await finishReportFailure(db, jobId, attemptCount, code);
  }
}

export async function processDueOperationalJobs(
  db: admin.firestore.Firestore,
  graphConfig: GraphConfig,
): Promise<void> {
  const now = admin.firestore.Timestamp.now();
  const [notifications, reports] = await Promise.all([
    db.collection("notificationJobs").where("status", "in", ["PENDING", "RETRYING"])
      .where("nextRetryAt", "<=", now).limit(25).get(),
    db.collection("reportSyncJobs").where("status", "in", ["PENDING", "RETRYING"])
      .where("nextRetryAt", "<=", now).limit(25).get(),
  ]);
  await Promise.all([
    ...notifications.docs.map((doc) => processNotificationJob(db, doc.id)),
    ...reports.docs.map((doc) => processReportSyncJob(db, doc.id, graphConfig)),
  ]);
}

async function claimJob(
  db: admin.firestore.Firestore,
  collection: "notificationJobs" | "reportSyncJobs",
  jobId: string,
): Promise<{job: JobRecord; attemptCount: number} | null> {
  const ref = db.collection(collection).doc(jobId);
  const now = admin.firestore.Timestamp.now();
  return db.runTransaction(async (tx) => {
    const doc = await tx.get(ref);
    if (!doc.exists) return null;
    const job = doc.data() as JobRecord;
    const dueAt = job.nextRetryAt?.toMillis() ?? 0;
    const staleLease = job.status === "PROCESSING" &&
      (job.leaseExpiresAt?.toMillis() ?? 0) <= now.toMillis();
    if (!(["PENDING", "RETRYING"].includes(job.status) && dueAt <= now.toMillis()) && !staleLease) return null;
    const attemptCount = Number(job.attemptCount ?? 0) + 1;
    tx.update(ref, {
      status: "PROCESSING",
      attemptCount,
      processingStartedAt: now,
      leaseExpiresAt: admin.firestore.Timestamp.fromMillis(now.toMillis() + 10 * 60 * 1000),
      updatedAt: now,
    });
    return {job, attemptCount};
  });
}

async function resolveDevices(db: admin.firestore.Firestore, job: JobRecord): Promise<DeviceRecord[]> {
  const retryPaths = Array.isArray(job.retryDevicePaths) ? job.retryDevicePaths as string[] : [];
  if (retryPaths.length > 0) {
    const docs = await db.getAll(...retryPaths.slice(0, 500).map((path) => db.doc(path)));
    return dedupeDevices(docs.filter((doc) => doc.exists && doc.get("enabled") === true)
      .map((doc) => ({path: doc.ref.path, token: String(doc.get("token") ?? ""), locale: String(doc.get("locale") ?? "en")})));
  }
  if (job.recipientKind === "admin") {
    const snapshot = await db.collectionGroup("devices").where("enabled", "==", true)
      .where("role", "==", "admin").limit(500).get();
    return dedupeDevices(snapshot.docs.map((doc) => ({
      path: doc.ref.path, token: String(doc.get("token") ?? ""), locale: "en",
    })));
  }
  const uid = String(job.recipientUserId ?? "");
  if (!uid) return [];
  const snapshot = await db.collection("users").doc(uid).collection("devices")
    .where("enabled", "==", true).limit(25).get();
  return dedupeDevices(snapshot.docs.map((doc) => ({
    path: doc.ref.path, token: String(doc.get("token") ?? ""), locale: String(doc.get("locale") ?? "en"),
  })));
}

async function completeNotification(
  db: admin.firestore.Firestore, jobId: string, attempts: number, result: string,
): Promise<void> {
  const now = admin.firestore.Timestamp.now();
  await Promise.all([
    db.collection("notificationJobs").doc(jobId).set({
      status: "COMPLETED", completedAt: now, updatedAt: now, leaseExpiresAt: null,
      deliveryResult: result, retryDevicePaths: admin.firestore.FieldValue.delete(), lastError: null,
    }, {merge: true}),
    db.collection("notificationLogs").doc(jobId).set({
      notificationId: jobId, status: result, attempts, sentAt: result === "SENT" ? now : null,
      updatedAt: now,
    }, {merge: true}),
  ]);
}

async function retryNotification(
  db: admin.firestore.Firestore, jobId: string, attempts: number,
  retryDevicePaths: string[], failureCode: string,
): Promise<void> {
  const decision = retryDecision(attempts, failureCode);
  const now = admin.firestore.Timestamp.now();
  const nextRetryAt = decision.delayMinutes == null ? null :
    admin.firestore.Timestamp.fromMillis(now.toMillis() + decision.delayMinutes * 60 * 1000);
  await Promise.all([
    db.collection("notificationJobs").doc(jobId).set({
      status: decision.status, nextRetryAt, lastError: failureCode, updatedAt: now,
      leaseExpiresAt: null, retryDevicePaths: retryDevicePaths.length > 0 ? retryDevicePaths : admin.firestore.FieldValue.delete(),
    }, {merge: true}),
    db.collection("notificationLogs").doc(jobId).set({
      notificationId: jobId, status: decision.status, attempts, lastError: failureCode, updatedAt: now,
    }, {merge: true}),
  ]);
}

async function finishReportFailure(
  db: admin.firestore.Firestore, jobId: string, attempts: number, failureCode: string,
): Promise<void> {
  const decision = retryDecision(attempts, failureCode);
  const now = admin.firestore.Timestamp.now();
  const nextRetryAt = decision.delayMinutes == null ? null :
    admin.firestore.Timestamp.fromMillis(now.toMillis() + decision.delayMinutes * 60 * 1000);
  const job = await db.collection("reportSyncJobs").doc(jobId).get();
  await Promise.all([
    db.collection("reportSyncJobs").doc(jobId).set({
      status: decision.status, nextRetryAt, lastError: failureCode, updatedAt: now, leaseExpiresAt: null,
    }, {merge: true}),
    db.collection("reportSyncState").doc(String(job.get("entityId") ?? jobId)).set({
      orderId: String(job.get("entityId") ?? jobId), status: decision.status,
      lastError: failureCode, updatedAt: now,
    }, {merge: true}),
  ]);
}

export class ReportingError extends Error {
  constructor(readonly code: string, readonly status?: number) {
    super(code);
  }
}

function isGraphConfigured(config: GraphConfig): boolean {
  return Object.values(config).every((value) => value.trim().length > 0);
}

class MicrosoftGraphReportingService {
  constructor(private readonly config: GraphConfig) {}

  async upsertOrder(order: admin.firestore.DocumentData & {id: string}): Promise<void> {
    const token = await this.accessToken();
    const orderRows = await this.tableRows(token, this.config.ordersTable);
    const orderValues = orderReportRow(order);
    const existing = orderRows.find((row) => String(row.values?.[0]?.[0] ?? "") === order.id);
    await this.upsertRow(token, this.config.ordersTable, existing?.index, orderValues);

    const itemRows = await this.tableRows(token, this.config.orderItemsTable);
    const byKey = new Map(itemRows.map((row) => [String(row.values?.[0]?.[0] ?? ""), row.index]));
    const items = Array.isArray(order.items) ? order.items as admin.firestore.DocumentData[] : [];
    await Promise.all(items.map((item, index) => this.upsertRow(token, this.config.orderItemsTable,
      byKey.get(`${order.id}_${index}`), orderItemReportRow(order, item, index))));
  }

  private async accessToken(): Promise<string> {
    const body = new URLSearchParams({
      client_id: this.config.clientId,
      client_secret: this.config.clientSecret,
      scope: "https://graph.microsoft.com/.default",
      grant_type: "client_credentials",
    });
    const response = await fetch(`https://login.microsoftonline.com/${encodeURIComponent(this.config.tenantId)}/oauth2/v2.0/token`, {
      method: "POST", headers: {"Content-Type": "application/x-www-form-urlencoded"}, body,
    });
    if (!response.ok) throw new ReportingError("CONFIGURATION_REQUIRED", response.status);
    const payload = await response.json() as {access_token?: string};
    if (!payload.access_token) throw new ReportingError("CONFIGURATION_REQUIRED");
    return payload.access_token;
  }

  private async tableRows(token: string, table: string): Promise<Array<{index: number; values: unknown[][]}>> {
    const rows: Array<{index: number; values: unknown[][]}> = [];
    let url: string | null = this.tableUrl(table) + "/rows?$top=100";
    while (url && rows.length < 10000) {
      const payload = await this.graph(token, url) as {value?: Array<{index?: number; values?: unknown[][]}>; "@odata.nextLink"?: string};
      rows.push(...(payload.value ?? []).map((row) => ({index: Number(row.index ?? -1), values: row.values ?? []})));
      url = payload["@odata.nextLink"] ?? null;
    }
    return rows;
  }

  private async upsertRow(token: string, table: string, index: number | undefined, values: unknown[]): Promise<void> {
    const url = index == null || index < 0 ? `${this.tableUrl(table)}/rows/add` :
      `${this.tableUrl(table)}/rows/itemAt(index=${index})`;
    await this.graph(token, url, index == null || index < 0 ? "POST" : "PATCH", {
      ...(index == null || index < 0 ? {index: null} : {}), values: [values],
    });
  }

  private tableUrl(table: string): string {
    return `https://graph.microsoft.com/v1.0/drives/${encodeURIComponent(this.config.driveId)}/items/${encodeURIComponent(this.config.workbookItemId)}/workbook/tables/${encodeURIComponent(table)}`;
  }

  private async graph(token: string, url: string, method = "GET", body?: unknown): Promise<unknown> {
    const response = await fetch(url, {
      method,
      headers: {Authorization: `Bearer ${token}`, "Content-Type": "application/json"},
      ...(body == null ? {} : {body: JSON.stringify(body)}),
    });
    if (!response.ok) {
      if (response.status === 429 || response.status >= 500) throw new ReportingError("TRANSIENT", response.status);
      throw new ReportingError("PERMANENT", response.status);
    }
    if (response.status === 204) return {};
    return response.json();
  }
}

export function orderReportRow(order: admin.firestore.DocumentData & {id: string}): unknown[] {
  const items = Array.isArray(order.items) ? order.items as admin.firestore.DocumentData[] : [];
  return [
    order.id, String(order.orderNumber ?? ""), isoDate(order.createdAt), String(order.customerName ?? ""),
    String(order.phoneNumber ?? ""), String(order.locationName ?? ""), String(order.deliveryAddress ?? ""),
    items.map((item) => `${String(item.productName ?? "")} x${Number(item.quantity ?? 0)}`).join("; "),
    items.length, Number(order.estimatedSubtotal ?? 0), nullableNumber(order.confirmedSubtotal),
    Number(order.deliveryCharge ?? 0), nullableNumber(order.finalTotal), String(order.paymentStatus ?? "pending"),
    String(order.orderStatus ?? "pending"), String(order.customerNote ?? ""), String(order.adminNote ?? ""), isoDate(order.updatedAt),
  ];
}

export function orderItemReportRow(order: admin.firestore.DocumentData & {id: string}, item: admin.firestore.DocumentData, index: number): unknown[] {
  return [
    `${order.id}_${index}`, String(order.orderNumber ?? ""), String(item.productId ?? ""),
    String(item.productName ?? ""), Number(item.quantity ?? 0), String(item.unit ?? ""),
    Number(item.priceAtOrder ?? 0), Number(item.subtotal ?? 0), String(order.locationName ?? ""),
  ];
}

function nullableNumber(value: unknown): number | "" {
  return value == null ? "" : Number(value);
}

function isoDate(value: unknown): string {
  if (value instanceof admin.firestore.Timestamp) return value.toDate().toISOString();
  if (value instanceof Date) return value.toISOString();
  return String(value ?? "");
}
