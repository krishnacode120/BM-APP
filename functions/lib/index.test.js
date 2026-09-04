"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const index_1 = require("./index");
function assert(value, message) {
    if (!value)
        throw new Error(message);
}
assert(index_1.testHooks.canTransition("pending", "verified"), "pending can verify");
assert(index_1.testHooks.canTransition("verified", "confirmed"), "verified can confirm");
assert(index_1.testHooks.canTransition("confirmed", "processing"), "confirmed can process");
assert(index_1.testHooks.canTransition("processing", "ready"), "processing can ready");
assert(index_1.testHooks.canTransition("ready", "completed"), "ready can complete");
assert(!index_1.testHooks.canTransition("completed", "pending"), "completed cannot revert");
assert(!index_1.testHooks.canTransition("pending", "unknown"), "unknown status rejected");
const searchTerms = index_1.testHooks.buildSearchTerms(["Red Clay Brick", "செங்கல்", "red brick"]);
assert(searchTerms.includes("red brick"), "English search phrase is indexed");
assert(searchTerms.includes("செங்கல்"), "Tamil search phrase is indexed");
const reportRows = [{
        id: "order-a",
        orderNumber: "BM10001",
        customerName: "தமிழ் வாடிக்கையாளர்",
        estimatedSubtotal: 100,
        finalTotal: 100,
        paymentStatus: "paid",
        orderStatus: "completed",
        items: [],
    }];
assert(index_1.testHooks.ordersCsv(reportRows).includes("தமிழ் வாடிக்கையாளர்"), "CSV preserves Unicode customer data");
assert(index_1.testHooks.revenueCsv([...reportRows, { ...reportRows[0], id: "cancelled", orderStatus: "cancelled" }])
    .split("\n").length === 2, "revenue CSV excludes cancelled orders");
//# sourceMappingURL=index.test.js.map