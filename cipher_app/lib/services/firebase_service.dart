import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cipher_app/firebase_options.dart';

/// Central service for Firebase initialization and global access.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  static bool _initialized = false;

  /// Initializes Firebase (call at app startup)
  static Future<void> initialize() async {
    if (!_initialized) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    }
  }

  /// Global Firestore instance
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Global Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  /// Global Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Handle/Log errors for Firebase operations
  static void logError(String message, dynamic error) {
    debugPrint('Firebase Error: $message - $error');
  }
}
