import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for handling Firestore timestamp conversions safely
class FirestoreTimestampHelper {
  /// Safely converts a Firestore field to DateTime
  /// Handles both Timestamp objects and null values
  static DateTime? toDateTime(dynamic firestoreField) {
    if (firestoreField == null) {
      return null;
    }

    if (firestoreField is Timestamp) {
      return firestoreField.toDate();
    }

    // Handle edge cases where data might be stored as string or milliseconds
    if (firestoreField is String) {
      return DateTime.tryParse(firestoreField);
    }

    if (firestoreField is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(firestoreField);
      } catch (e) {
        return null;
      }
    }

    // If we can't parse it, return null
    return null;
  }

  /// Safely converts a DateTime to Firestore Timestamp
  /// Returns null if input is null
  static Timestamp? fromDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }

    try {
      return Timestamp.fromDate(dateTime);
    } catch (e) {
      return null;
    }
  }

  /// For server-side timestamp generation (create operations)
  static FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }

  /// Safe conversion for local SQLite storage
  static String? toSqliteString(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  /// Safe conversion from SQLite string to DateTime
  static DateTime? fromSqliteString(String? sqliteString) {
    if (sqliteString == null) return null;
    return DateTime.tryParse(sqliteString);
  }
}
