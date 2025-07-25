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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyC8n1xloMejpL893H9KrQ_YbbsjiMZD8J0',
    appId: '1:248536758153:web:59a2ceca67721abe5ed358',
    messagingSenderId: '248536758153',
    projectId: 'financial-advsory',
    authDomain: 'financial-advsory.firebaseapp.com',
    storageBucket: 'financial-advsory.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWnPMZNs4WhU3aurE5tQb3xWy3t1uhrRk',
    appId: '1:248536758153:android:81dc0427f2387ebe5ed358',
    messagingSenderId: '248536758153',
    projectId: 'financial-advsory',
    storageBucket: 'financial-advsory.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAZPKGMSI8AAS-Az9jIo2JWWRmFywzBTBk',
    appId: '1:248536758153:ios:36b91b19cdea59235ed358',
    messagingSenderId: '248536758153',
    projectId: 'financial-advsory',
    storageBucket: 'financial-advsory.firebasestorage.app',
    iosBundleId: 'com.example.frontendFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAZPKGMSI8AAS-Az9jIo2JWWRmFywzBTBk',
    appId: '1:248536758153:ios:36b91b19cdea59235ed358',
    messagingSenderId: '248536758153',
    projectId: 'financial-advsory',
    storageBucket: 'financial-advsory.firebasestorage.app',
    iosBundleId: 'com.example.frontendFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC8n1xloMejpL893H9KrQ_YbbsjiMZD8J0',
    appId: '1:248536758153:web:c317d3f07bf3fa085ed358',
    messagingSenderId: '248536758153',
    projectId: 'financial-advsory',
    authDomain: 'financial-advsory.firebaseapp.com',
    storageBucket: 'financial-advsory.firebasestorage.app',
  );
}
