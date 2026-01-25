// TODO: Replace this file by running: flutterfire configure
// This is a placeholder that allows the app to compile before Firebase setup.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS not configured yet');
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZ8L18Hp8nLxOBY4TSOS8zxR2a9EZwE-U',
    appId: '1:596254929406:android:1878a3a29d41a9213d50af',
    messagingSenderId: '596254929406',
    projectId: 'aspire-bc5d7',
    storageBucket: 'aspire-bc5d7.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase config
}