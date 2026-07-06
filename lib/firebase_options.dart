import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Firebase is not configured for Fuchsia.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDEnLfblQNepiIqY9809BeTxzLUFT-g5q4',
    appId: '1:218137391802:web:0d7497bfa76ff4db5ec883',
    messagingSenderId: '218137391802',
    projectId: 'alarm-clock-49afc',
    authDomain: 'alarm-clock-49afc.firebaseapp.com',
    storageBucket: 'alarm-clock-49afc.firebasestorage.app',
    measurementId: 'G-BVVY9T28BG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAzmv5uJfGYW8lX2w32qbUVfRiwwbfK3Ys',
    appId: '1:218137391802:android:6dbbca086ccdf7e85ec883',
    messagingSenderId: '218137391802',
    projectId: 'alarm-clock-49afc',
    storageBucket: 'alarm-clock-49afc.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB4M0Kq2Ovq0z5MW9E_C-HyTD9tQ9swklY',
    appId: '1:218137391802:ios:d07405081fe0399f5ec883',
    messagingSenderId: '218137391802',
    projectId: 'alarm-clock-49afc',
    storageBucket: 'alarm-clock-49afc.firebasestorage.app',
    iosBundleId: 'com.example.alarmclock',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB4M0Kq2Ovq0z5MW9E_C-HyTD9tQ9swklY',
    appId: '1:218137391802:ios:d07405081fe0399f5ec883',
    messagingSenderId: '218137391802',
    projectId: 'alarm-clock-49afc',
    storageBucket: 'alarm-clock-49afc.firebasestorage.app',
    iosBundleId: 'com.example.alarmclock',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEnLfblQNepiIqY9809BeTxzLUFT-g5q4',
    appId: '1:218137391802:web:14ba31ef4de41e1b5ec883',
    messagingSenderId: '218137391802',
    projectId: 'alarm-clock-49afc',
    authDomain: 'alarm-clock-49afc.firebaseapp.com',
    storageBucket: 'alarm-clock-49afc.firebasestorage.app',
    measurementId: 'G-0RN2LMDRWJ',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'replace-with-your-linux-api-key',
    appId: 'replace-with-your-linux-app-id',
    messagingSenderId: 'replace-with-your-sender-id',
    projectId: 'replace-with-your-project-id',
    authDomain: 'replace-with-your-project-id.firebaseapp.com',
    storageBucket: 'replace-with-your-project-id.firebasestorage.app',
  );
}
