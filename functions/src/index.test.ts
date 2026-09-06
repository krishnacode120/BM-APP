import {testHooks} from "./index";
import * as admin from "firebase-admin";

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

for (const value of ["=1+1", "+SUM(1,2)", "-1+1", "@SUM(1)", "  =1", "\tvalue", "\rvalue"]) {
  const output = testHooks.customersCsv([{id: "customer", name: value}]);
  assert(output.includes(`"'${value.replace(/"/g, '""')}"`),
    "CSV formula-like text must be exported as literal text");
}
assert(testHooks.productsCsv([{id: "p", name: 'Brick, "A"', stockQuantity: -2}])
  .includes('"Brick, ""A"""'), "CSV still escapes commas and quotes");
assert(testHooks.productsCsv([{id: "p", stockQuantity: -2}]).includes('"-2"'),
  "numeric cells remain numeric");

async function testCurrentPrice() {
  const now = admin.firestore.Timestamp.fromMillis(100000);
  const db = admin.firestore();
  const expectedQuery = db.collection("productPrices")
    .where("productId", "==", "product").where("locationId", "==", "location")
    .where("effectiveFrom", "<=", now).orderBy("effectiveFrom", "desc").limit(5);
  let rows: admin.firestore.DocumentData[] = [];
  const transaction = {
    get: async (query: admin.firestore.Query) => {
      assert(query.isEqual(expectedQuery), "current price filters future prices before limit");
      return {docs: rows.map((data) => ({data: () => data}))};
    },
  } as unknown as admin.firestore.Transaction;
  const read = () => testHooks.currentPrice(transaction, "product", "location", now);
  assert(await read() === null, "missing price is not zero");
  rows = [{price: 8.5, effectiveFrom: now}];
  assert(await read() === 8.5, "price includes effectiveFrom boundary");
  rows = [{price: 9, effectiveTo: now}, {price: 8, effectiveFrom: now}];
  assert(await read() === 8, "effectiveTo boundary is exclusive");
  for (const price of [-1, NaN, Infinity, "8", undefined]) {
    rows = [{price, effectiveFrom: now}];
    assert(await read() === null, "malformed price is rejected");
  }
}
void testCurrentPrice().catch((error) => { console.error(error); process.exitCode = 1; });
