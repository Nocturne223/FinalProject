import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseEmulatorConfig {
  FirebaseEmulatorConfig._();
  static bool usingEmulator = false;
}

Future<void> configureFirebaseEmulators() async {
  const bool useEmulator = bool.fromEnvironment(
    'USE_EMULATOR',
    defaultValue: false,
  );
  if (!useEmulator) return;

  final String host;
  if (kIsWeb) {
    host = 'localhost';
  } else {
    host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  }

  // Firestore
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  // Auth
  await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  // Storage
  FirebaseStorage.instance.useStorageEmulator(host, 9199);

  FirebaseEmulatorConfig.usingEmulator = true;
}
