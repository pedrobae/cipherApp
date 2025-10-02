/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { setGlobalOptions } = require("firebase-functions");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

async function updatePopularCiphers() {
  try {
    const ciphersRef = admin.firestore().collection("publicCiphers");
    const snapshot = await ciphersRef.orderBy("downloadCount", "desc")
      .limit(20).get();

    const popularCiphers = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));

    await admin.firestore().doc("stats/popularCiphers").set({
      ciphers: popularCiphers,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("Popular ciphers updated successfully.");

  } catch (error) {
    console.error("Error updating popular ciphers:", error);
  }
}

async function getAnalyticsData(eventName, dateRange) {
  try {
    // For now, return empty array since Analytics API requires additional setup
    // You can implement the full Analytics Reporting API later
    console.log(`📊 Analytics data requested for ${eventName} (${dateRange})`);

    // TODO: Implement actual Firebase Analytics Reporting API
    // This requires setting up service account credentials and Analytics API

    return [];
  } catch (error) {
    console.error("❌ Error fetching analytics data:", error);
    return [];
  }
}

exports.aggregateCipherDownloads = functions.pubsub
  .schedule("every 24 hours")
  .timeZone("America/Sao_Paulo")
  .onRun(async (_) => {
    try {
      const analyticsData = await getAnalyticsData("cipher_downloaded", "last_24_hours");

      if (analyticsData && analyticsData.length > 0) {
        const downloadCounts = {};
        analyticsData.forEach(({ cipher_Id }) => {
          downloadCounts[cipher_Id] = (downloadCounts[cipher_Id] || 0) + 1;
        });


        const batch = admin.firestore().batch();
        Object.entries(downloadCounts).forEach(([cipher_Id, downloadCount]) => {
          const cipherRef = admin.firestore().collection("publicCiphers").doc(cipher_Id);
          batch.update(cipherRef, { downloadCount: admin.firestore.FieldValue.increment(downloadCount), });
        });
        await batch.commit();
      }

      await updatePopularCiphers();

    } catch (error) {
      console.error("Error aggregating cipher downloads:", error);
    }
  });