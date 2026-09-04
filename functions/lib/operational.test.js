"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const operational_1 = require("./operational");
function assert(value, message) {
    if (!value)
        throw new Error(message);
}
const tamil = (0, operational_1.notificationTemplate)("ORDER_CONFIRMED", "ta", "BM10025");
assert(tamil.title === "ஆர்டர் உறுதிப்படுத்தப்பட்டது", "Tamil notification title");
assert(tamil.body.includes("BM10025"), "notification includes order number");
assert((0, operational_1.retryDecision)(1, "TRANSIENT").status === "RETRYING", "transient failures retry");
assert((0, operational_1.retryDecision)(5, "TRANSIENT").status === "DEAD_LETTER", "retries dead-letter");
assert((0, operational_1.retryDecision)(1, "CONFIGURATION_REQUIRED").status === "FAILED", "missing Graph config is visible");
assert((0, operational_1.dedupeDevices)([
    { path: "users/a/devices/one", token: "token-a", locale: "en" },
    { path: "users/a/devices/two", token: "token-a", locale: "ta" },
]).length === 1, "tokens are deduplicated");
const order = {
    id: "order-a",
    orderNumber: "BM10025",
    customerName: "Customer",
    phoneNumber: "9876543210",
    locationName: "Karaikudi, Tamil Nadu",
    items: [{ productId: "brick", productName: "Red Brick", quantity: 10, unit: "piece", priceAtOrder: 8, subtotal: 80 }],
    estimatedSubtotal: 80,
    paymentStatus: "unpaid",
    orderStatus: "pending",
};
assert((0, operational_1.orderReportRow)(order)[0] === "order-a", "order report uses stable external key");
assert((0, operational_1.orderItemReportRow)(order, order.items[0], 0)[0] === "order-a_0", "item report uses stable key");
//# sourceMappingURL=operational.test.js.map