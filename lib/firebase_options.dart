// File generated from your Firebase project (google-services.json).
// Used by Firebase.initializeApp() so the app knows which Firebase
// project to talk to. These values are NOT secret.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not configured for this app. Please run on an Android emulator.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'This app is configured for Android only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSDUTrwVNxvzElDv4BqKmJtK7Lopw9m9g',
    appId: '1:755261339439:android:f5f2aa361e748f6a8a93da',
    messagingSenderId: '755261339439',
    projectId: 'mbap-6e9d4',
    storageBucket: 'mbap-6e9d4.firebasestorage.app',
  );
}
