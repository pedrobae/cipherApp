/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");

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
setGlobalOptions({maxInstances: 10});

const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.updatePopularCiphers = functions.pubsub.schedule("every 24 hours")
    .onRun(async (context) => {
      const ciphersRef = admin.firestore().collection("publicCiphers");
      const snapshot = await ciphersRef.orderBy("downloadCount", "desc")
          .limit(20).get();
      const popularCiphers = snapshot.docs.map((doc) => doc.data());

      await admin.firestore().doc("stats/popularCiphers").set({
        ciphers: popularCiphers,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
