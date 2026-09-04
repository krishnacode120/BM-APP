/*
 * Development-only catalog seed. Requires trusted Admin SDK credentials or the
 * Firebase emulator. It refuses to run unless explicitly enabled.
 *
 *   $env:BM_ALLOW_DEVELOPMENT_SEED='true'
 *   $env:BM_SEED_ENV='development'
 *   node scripts/seed-development-data.js
 */
const admin = require("firebase-admin");

if (process.env.BM_ALLOW_DEVELOPMENT_SEED !== "true" || process.env.BM_SEED_ENV !== "development") {
  throw new Error("Set BM_ALLOW_DEVELOPMENT_SEED=true and BM_SEED_ENV=development before seeding.");
}

admin.initializeApp();
const db = admin.firestore();
const now = admin.firestore.Timestamp.now();

const locations = [
  ["karaikudi", "Karaikudi", "Sivaganga"],
  ["madurai", "Madurai", "Madurai"],
  ["coimbatore", "Coimbatore", "Coimbatore"],
  ["chennai", "Chennai", "Chennai"],
];

const categories = [
  ["bricks", "Bricks", "செங்கற்கள்"],
  ["sand", "Sand", "மணல்"],
  ["cement", "Cement", "சிமெண்டு"],
  ["jelly", "Jelly", "ஜல்லி"],
  ["steel", "Steel", "எஃகு"],
  ["concrete-blocks", "Concrete Blocks", "கான்கிரீட் கட்டைகள்"],
  ["rmc", "RMC", "ரெடி மிக்ஸ் கான்கிரீட்"],
  ["other-materials", "Other Materials", "மற்ற பொருட்கள்"],
];

const products = [
  ["red-clay-brick", "Red Clay Brick", "செங்கல்", "bricks", "piece", 500, "available", [8, 8.5, 9, 10]],
  ["fly-ash-brick", "Fly Ash Brick", "ஃப்ளை ஆஷ் செங்கல்", "bricks", "piece", 500, "available", [7, 7.5, 8, 9]],
  ["hollow-block", "Hollow Block", "ஹாலோ பிளாக்", "concrete-blocks", "piece", 100, "available", [42, 44, 46, 50]],
  ["m-sand", "M-Sand", "எம்-சாண்ட்", "sand", "load", 1, "available", [5200, 5400, 5600, 6000]],
  ["20mm-jelly", "20mm Jelly", "20மிமீ ஜல்லி", "jelly", "load", 1, "lowStock", [4600, 4800, 5000, 5400]],
  ["opc-cement", "OPC Cement", "ஓபிசி சிமெண்டு", "cement", "bag", 10, "available", [430, 435, 440, 450]],
  ["tmt-steel", "TMT Steel", "டிஎம்டி எஃகு", "steel", "ton", 1, "comingSoon", [56000, 56500, 57000, 58000]],
];

async function seed() {
  const batch = db.batch();
  for (const [id, city, district] of locations) {
    batch.set(db.collection("locations").doc(id), {
      city, district, state: "Tamil Nadu", country: "India", active: true,
      createdAt: now, updatedAt: now,
    }, {merge: true});
  }
  categories.forEach(([id, name, nameTamil], index) => {
    batch.set(db.collection("categories").doc(id), {
      name, nameTamil, description: `${name} for BM development testing`,
      descriptionTamil: `${nameTamil} - BM மேம்பாட்டு சோதனை`, imageUrl: null,
      sortOrder: index + 1, isActive: true, createdAt: now, updatedAt: now,
    }, {merge: true});
  });
  for (const [id, name, nameTamil, categoryId, unit, minimumOrderQuantity, stockStatus, prices] of products) {
    batch.set(db.collection("products").doc(id), {
      name, nameTamil, categoryId,
      description: `${name} development catalog record`,
      descriptionTamil: `${nameTamil} மேம்பாட்டு பட்டியல் பதிவு`,
      images: [], thumbnail: null, brand: "BM Development", unit,
      minimumOrderQuantity, stockStatus, stockQuantity: null,
      specifications: {}, keywords: [name.toLowerCase(), nameTamil],
      searchTerms: [name.toLowerCase(), ...name.toLowerCase().split(" "), nameTamil],
      isPopular: ["red-clay-brick", "m-sand", "opc-cement"].includes(id),
      isFeatured: id === "red-clay-brick", isActive: true,
      createdAt: now, updatedAt: now, createdBy: "development-seed", updatedBy: "development-seed",
    }, {merge: true});
    locations.forEach(([locationId], index) => {
      batch.set(db.collection("productPrices").doc(`dev_${id}_${locationId}`), {
        productId: id, locationId, price: prices[index], effectiveFrom: now,
        effectiveTo: null, updatedAt: now, updatedBy: "development-seed",
      }, {merge: true});
    });
  }
  batch.set(db.collection("settings").doc("app"), {
    businessName: "BM",
    businessPhone: "+917708538700",
    whatsappNumber: "+91XXXXXXXXXX",
    supportEmail: "",
    defaultCurrency: "INR",
    supportHours: "",
    updatedAt: now,
    developmentOnly: true,
  }, {merge: true});
  await batch.commit();
  console.log("Seeded BM development catalog. Complete the remaining contact settings before client testing.");
}

seed().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
