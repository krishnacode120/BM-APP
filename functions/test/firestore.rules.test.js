const fs = require("fs");
const path = require("path");
const assert = require("assert");
const {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} = require("@firebase/rules-unit-testing");

let testEnv;

describe("firestore security rules", () => {
  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: "bm-test",
      firestore: {
        rules: fs.readFileSync(path.resolve(__dirname, "../../firestore.rules"), "utf8"),
      },
    });
  });

  after(async () => {
    await testEnv.cleanup();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.collection("orders").doc("order-a").set({userId: "user-a"});
      await db.collection("orders").doc("order-b").set({userId: "user-b"});
      await db.collection("products").doc("product-a").set({
        isActive: true,
        stockStatus: "available",
      });
      await db.collection("categories").doc("category-a").set({isActive: true});
      await db.collection("productPrices").doc("price-a").set({price: 8});
      await db.collection("auditLogs").doc("audit-a").set({action: "PRICE_CHANGED"});
    });
  });

  it("lets users read only their own orders", async () => {
    const userA = testEnv.authenticatedContext("user-a").firestore();
    await assertSucceeds(userA.collection("orders").doc("order-a").get());
    await assertFails(userA.collection("orders").doc("order-b").get());
  });

  it("blocks normal users from catalog, price, and audit writes", async () => {
    const userA = testEnv.authenticatedContext("user-a").firestore();
    await assertFails(userA.collection("products").doc("product-a").update({name: "X"}));
    await assertFails(userA.collection("categories").doc("category-a").update({name: "X"}));
    await assertFails(userA.collection("productPrices").doc("price-a").update({price: 9}));
    await assertFails(userA.collection("auditLogs").doc("audit-b").set({action: "X"}));
  });

  it("allows admin claim catalog writes and audit reads", async () => {
    const adminDb = testEnv.authenticatedContext("admin-a", {admin: true, role: "admin"}).firestore();
    await assertSucceeds(adminDb.collection("products").doc("product-a").update({name: "X"}));
    await assertSucceeds(adminDb.collection("categories").doc("category-a").update({name: "X"}));
    await assertSucceeds(adminDb.collection("productPrices").doc("price-a").update({price: 9}));
    await assertSucceeds(adminDb.collection("auditLogs").doc("audit-a").get());
  });

  it("blocks unauthenticated protected reads", async () => {
    const anon = testEnv.unauthenticatedContext().firestore();
    await assertFails(anon.collection("orders").doc("order-a").get());
    await assertFails(anon.collection("auditLogs").doc("audit-a").get());
    assert.ok(true);
  });
});
