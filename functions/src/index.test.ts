import {testHooks} from "./index";

function assert(value: boolean, message: string) {
  if (!value) throw new Error(message);
}

assert(testHooks.canTransition("pending", "verified"), "pending can verify");
assert(testHooks.canTransition("verified", "confirmed"), "verified can confirm");
assert(testHooks.canTransition("confirmed", "processing"), "confirmed can process");
assert(testHooks.canTransition("processing", "ready"), "processing can ready");
assert(testHooks.canTransition("ready", "completed"), "ready can complete");
assert(!testHooks.canTransition("completed", "pending"), "completed cannot revert");
assert(!testHooks.canTransition("pending", "unknown"), "unknown status rejected");

const searchTerms = testHooks.buildSearchTerms(["Red Clay Brick", "செங்கல்", "red brick"]);
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
assert(testHooks.ordersCsv(reportRows).includes("தமிழ் வாடிக்கையாளர்"),
  "CSV preserves Unicode customer data");
assert(testHooks.revenueCsv([...reportRows, {...reportRows[0], id: "cancelled", orderStatus: "cancelled"}])
  .split("\n").length === 2, "revenue CSV excludes cancelled orders");
