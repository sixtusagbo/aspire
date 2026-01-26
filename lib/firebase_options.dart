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
        return ios;
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

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrNTznhG_5jsdIhQUHw7LH631ZSToMyVM',
    appId: '1:596254929406:ios:658ea771e916c2e43d50af',
    messagingSenderId: '596254929406',
    projectId: 'aspire-bc5d7',
    storageBucket: 'aspire-bc5d7.firebasestorage.app',
    androidClientId: '596254929406-1312cokujheaffjo8o44tv5m0g8u3eoq.apps.googleusercontent.com',
    iosClientId: '596254929406-b9f2tp9va52q93rk5ibu3veehp6630h3.apps.googleusercontent.com',
    iosBundleId: 'com.sixtusagbo.aspire',
  );

}