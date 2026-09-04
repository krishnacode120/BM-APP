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
      await db.collection("users").doc("user-a").collection("devices").doc("device-a").set({token: "secret-token", enabled: true});
      await db.collection("notificationJobs").doc("job-a").set({status: "PENDING"});
      await db.collection("reportSyncJobs").doc("order-a").set({status: "PENDING"});
      await db.collection("settings").doc("app").set({businessName: "BM", businessPhone: "+91XXXXXXXXXX"});
      await db.collection("settings").doc("internal").set({secret: "not-public"});
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

  it("allows a verified phone customer profile without privilege escalation", async () => {
    const customer = testEnv.authenticatedContext("customer-a", {
      phone_number: "+919876543210",
    }).firestore();
    const profile = customer.collection("users").doc("customer-a");
    await assertSucceeds(profile.set({
      uid: "customer-a",
      name: "Customer",
      phoneNumber: "+919876543210",
      role: "customer",
      phoneVerified: true,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
    await assertSucceeds(profile.update({name: "Updated Customer", updatedAt: new Date()}));
    await assertFails(profile.update({role: "admin"}));
    await assertFails(profile.update({phoneNumber: "+919999999999"}));
  });

  it("rejects spoofed customer profile phone and role", async () => {
    const customer = testEnv.authenticatedContext("customer-b", {
      phone_number: "+919876543210",
    }).firestore();
    const base = {
      uid: "customer-b",
      name: "Customer",
      phoneNumber: "+919999999999",
      role: "customer",
      phoneVerified: true,
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    await assertFails(customer.collection("users").doc("customer-b").set(base));
    await assertFails(customer.collection("users").doc("customer-b").set({
      ...base,
      phoneNumber: "+919876543210",
      role: "admin",
    }));
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

  it("keeps device tokens and system jobs backend-only", async () => {
    const userA = testEnv.authenticatedContext("user-a").firestore();
    const adminDb = testEnv.authenticatedContext("admin-a", {admin: true}).firestore();
    await assertFails(userA.collection("users").doc("user-a").collection("devices").doc("device-a").get());
    await assertFails(userA.collection("notificationJobs").doc("job-a").get());
    await assertFails(userA.collection("notificationJobs").doc("job-a").update({status: "COMPLETED"}));
    await assertFails(userA.collection("reportSyncJobs").doc("order-a").get());
    await assertFails(userA.collection("reportSyncJobs").doc("order-a").update({status: "COMPLETED"}));
    await assertSucceeds(adminDb.collection("notificationJobs").doc("job-a").get());
    await assertSucceeds(adminDb.collection("reportSyncJobs").doc("order-a").get());
  });

  it("allows customer reads of public contact settings only", async () => {
    const userA = testEnv.authenticatedContext("user-a").firestore();
    await assertSucceeds(userA.collection("settings").doc("app").get());
    await assertFails(userA.collection("settings").doc("app").update({businessPhone: "+919999999999"}));
    await assertFails(userA.collection("settings").doc("internal").get());
  });
});
