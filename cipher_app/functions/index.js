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
setGlobalOptions({maxInstances: 5});

const functions = require("firebase-functions");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const {BigQuery} = require("@google-cloud/bigquery");

admin.initializeApp();

/**
 * Updates the popular ciphers list in Firestore stats collection
 */
async function updatePopularCiphers() {
  try {
    const ciphersRef = admin.firestore().collection("publicCiphers");
    const snapshot = await ciphersRef
        .orderBy("downloadCount", "desc")
        .limit(20)
        .get();

    const popularCiphers = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    await admin.firestore().doc("stats/popularCiphers").set({
      ciphers: popularCiphers,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log("Popular ciphers updated successfully.");
  } catch (error) {
    console.error("Error updating popular ciphers:", error);
    throw error;
  }
}


/**
 * Parses period specification for BigQuery date filtering
 * @param {string} period - Period specification
 * @return {Object} Object containing whereClause for BigQuery
 */
function parsePeriodForBigQuery(period) {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  switch (period) {
    case "yesterday": {
      const yesterday = new Date(today);
      yesterday.setDate(yesterday.getDate() - 1);
      const dateString = yesterday.toISOString().slice(0, 10)
          .replace(/-/g, "");
      return {
        whereClause: `_TABLE_SUFFIX = '${dateString}'`,
      };
    }

    case "last_7_days": {
      const endDate = new Date(today);
      endDate.setDate(endDate.getDate() - 1); // Yesterday
      const startDate = new Date(endDate);
      startDate.setDate(startDate.getDate() - 6); // 7 days total

      const startString = startDate.toISOString().slice(0, 10)
          .replace(/-/g, "");
      const endString = endDate.toISOString().slice(0, 10)
          .replace(/-/g, "");

      return {
        whereClause: `_TABLE_SUFFIX BETWEEN '${startString}' ` +
          `AND '${endString}'`,
      };
    }

    case "last_30_days": {
      const endDate = new Date(today);
      endDate.setDate(endDate.getDate() - 1); // Yesterday
      const startDate = new Date(endDate);
      startDate.setDate(startDate.getDate() - 29); // 30 days total

      const startString = startDate.toISOString().slice(0, 10)
          .replace(/-/g, "");
      const endString = endDate.toISOString().slice(0, 10)
          .replace(/-/g, "");

      return {
        whereClause: `_TABLE_SUFFIX BETWEEN '${startString}' ` +
          `AND '${endString}'`,
      };
    }

    default: {
      // Handle custom date range: 'YYYY-MM-DD,YYYY-MM-DD'
      if (period.includes(",")) {
        const [startDateStr, endDateStr] = period.split(",");
        const startString = startDateStr.replace(/-/g, "");
        const endString = endDateStr.replace(/-/g, "");

        return {
          whereClause: `_TABLE_SUFFIX BETWEEN '${startString}' ` +
            `AND '${endString}'`,
        };
      }

      // Default to yesterday if period is unrecognized
      console.warn(`Period not recognized: ${period}.`);
      return parsePeriodForBigQuery("yesterday");
    }
  }
}

/**
 * Fetches Firebase Analytics event data via BigQuery for a variable period
 * @param {string} eventName - The Analytics event name to query
 * @param {string} period - Period specification: 'yesterday', etc.
 * @return {Promise<Array>} Array of objects with cipher_id and download_count
 */
async function getAnalyticsData(eventName, period) {
  try {
    const bigquery = new BigQuery();

    // Get project ID from environment
    const projectId = process.env.GCLOUD_PROJECT;

    const analyticsPropertyId = "12240780969"; // Android app property ID

    const {whereClause} = parsePeriodForBigQuery(period);

    const query = `
      SELECT 
        (SELECT value.string_value 
         FROM UNNEST(event_params) 
         WHERE key = 'cipher_id') as cipher_id,
        COUNT(*) as download_count,
        FROM \`${projectId}.analytics_${analyticsPropertyId}.events_\`
      WHERE event_name = @eventName
        AND ${whereClause}
        AND (SELECT value.string_value 
             FROM UNNEST(event_params) 
             WHERE key = 'cipher_id') IS NOT NULL
      GROUP BY cipher_id
      HAVING download_count > 0
    `;

    const options = {
      query: query,
      params: {eventName: eventName},
    };

    const [rows] = await bigquery.query(options);

    return rows.map((row) => ({
      cipherId: row.cipher_id,
      downloadCount: parseInt(row.download_count),
    }));
  } catch (error) {
    console.error("Error querying BigQuery:", error);
    return [];
  }
}

exports.aggregateCipherDownloads = onSchedule("0 2 * * *", async (event) => {
  try {
    const data = await getAnalyticsData("cipher_downloaded", "yesterday");

    const batch = admin.firestore().batch();
    data.forEach(({cipherId, downloadCount}) => {
      const cipherRef = admin.firestore().collection("publicCiphers")
          .doc(cipherId);
      batch.update(cipherRef, {
        downloadCount: admin.firestore.FieldValue.increment(downloadCount),
      });
    });
    await batch.commit();

    await updatePopularCiphers();

    return {
      success: true,
      processedCiphers: data ? data.length : 0,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    console.error("Error aggregating cipher downloads:", error);
    throw error;
  }
});

// === ADMIN FUNCTIONS ===

// Grant admin privileges to a user (call this function manually)
exports.grantAdminRole = functions.https.onCall(async (data, context) => {
  // Only existing admins can grant admin role
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can grant admin role.",
    );
  }

  const {uid} = data;

  try {
    // Set custom claims
    await admin.auth().setCustomUserClaims(uid, {admin: true});

    return {
      message: `Admin role granted to user ${uid}`,
      success: true,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
        "internal",
        "Failed to grant admin role",
        error,
    );
  }
});

// Bootstrap function to grant first admin (run once manually)
exports.grantFirstAdmin = functions.https.onRequest(async (req, res) => {
  const {email, secret} = req.body;

  // Use a secret key for security
  if (secret !== "cipher-admin-secret-2025") {
    return res.status(403).json({error: "Invalid secret"});
  }

  try {
    // Find user by email
    const user = await admin.auth().getUserByEmail(email);

    // Grant admin privileges
    await admin.auth().setCustomUserClaims(user.uid, {admin: true});

    res.json({
      message: `First admin granted to ${email}`,
      uid: user.uid,
      success: true,
    });
  } catch (error) {
    res.status(500).json({error: error.message});
  }
});

// Remove admin role
exports.revokeAdminRole = functions.https.onCall(async (data, context) => {
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can revoke admin role.",
    );
  }

  const {uid} = data;

  try {
    await admin.auth().setCustomUserClaims(uid, {admin: false});

    return {
      message: `Admin role revoked from user ${uid}`,
      success: true,
    };
  } catch (error) {
    throw new functions.https.HttpsError(
        "internal",
        "Failed to revoke admin role",
        error,
    );
  }
});
