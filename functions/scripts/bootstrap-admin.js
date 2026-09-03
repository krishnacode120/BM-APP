const admin = require("firebase-admin");

const uid = process.argv[2];
if (!uid) {
  console.error("Usage: node scripts/bootstrap-admin.js <firebase-auth-uid>");
  process.exit(1);
}

admin.initializeApp();

async function main() {
  await admin.auth().setCustomUserClaims(uid, {admin: true, role: "admin"});
  await admin.firestore().collection("users").doc(uid).set({
    role: "admin",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedBy: "bootstrap-script",
  }, {merge: true});
  await admin.firestore().collection("auditLogs").add({
    actorUserId: "bootstrap-script",
    actorRole: "system",
    action: "ADMIN_CREATED",
    entityType: "user",
    entityId: uid,
    oldValue: null,
    newValue: {role: "admin"},
    metadata: {source: "bootstrap-admin.js"},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  console.log(`Admin claim assigned to ${uid}`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
