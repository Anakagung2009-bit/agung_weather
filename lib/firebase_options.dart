// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBS4SBVhyiRjC4z5udgz9vKPZIZ5Y-QqU8',
    appId: '1:324982137742:web:07c40b4a6dd299541ffadf',
    messagingSenderId: '324982137742',
    projectId: 'agung-dev-project',
    authDomain: 'agung-dev-project.firebaseapp.com',
    databaseURL: 'https://agung-dev-project-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'agung-dev-project.firebasestorage.app',
    measurementId: 'G-6HGCP88TVV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAd9Cng0eir-2SOa9WPgYvRa4bEhZAv96g',
    appId: '1:324982137742:android:316cc8b8e2dba9991ffadf',
    messagingSenderId: '324982137742',
    projectId: 'agung-dev-project',
    databaseURL: 'https://agung-dev-project-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'agung-dev-project.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBS4SBVhyiRjC4z5udgz9vKPZIZ5Y-QqU8',
    appId: '1:324982137742:web:9a3cbf0d0502cde01ffadf',
    messagingSenderId: '324982137742',
    projectId: 'agung-dev-project',
    authDomain: 'agung-dev-project.firebaseapp.com',
    databaseURL: 'https://agung-dev-project-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'agung-dev-project.firebasestorage.app',
    measurementId: 'G-83Q4DTZCMJ',
  );
}
