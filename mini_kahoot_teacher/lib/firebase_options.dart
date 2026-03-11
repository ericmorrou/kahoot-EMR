// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC60U4pBGv3jlQesGBO-Wavq-UmRdkWEo8',
    appId: '1:950392285371:web:367d2f4bdb4314681d619e',
    messagingSenderId: '950392285371',
    projectId: 'kahoot-emr',
    authDomain: 'kahoot-emr.firebaseapp.com',
    storageBucket: 'kahoot-emr.firebasestorage.app',
    measurementId: 'G-637GSBHPMK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC60U4pBGv3jlQesGBO-Wavq-UmRdkWEo8',
    appId: '1:950392285371:android:1c07d302965ce9a71d619e',
    messagingSenderId: '950392285371',
    projectId: 'kahoot-emr',
    storageBucket: 'kahoot-emr.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC60U4pBGv3jlQesGBO-Wavq-UmRdkWEo8',
    appId: '1:950392285371:web:367d2f4bdb4314681d619e',
    messagingSenderId: '950392285371',
    projectId: 'kahoot-emr',
    authDomain: 'kahoot-emr.firebaseapp.com',
    storageBucket: 'kahoot-emr.firebasestorage.app',
    measurementId: 'G-637GSBHPMK',
  );
}
