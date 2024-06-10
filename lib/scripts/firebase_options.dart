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

  static String get clientId {
    if (kIsWeb) {
      return '1031401823307-n1s116c4mortggf8dchnojmo8pupleot.apps.googleusercontent.com';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '1031401823307-n1s116c4mortggf8dchnojmo8pupleot.apps.googleusercontent.com';
      case TargetPlatform.iOS:
        return '1031401823307-cpi4g7pm06vap2qr09gc1p0mj8a0s6qt.apps.googleusercontent.com';
      case TargetPlatform.macOS:
        return 'com.googleusercontent.apps.1031401823307-nnuald2l89jpehervv54b96pcgre19uj';
      case TargetPlatform.windows:
        return 'Windows is currently not supported. Support coming soon.';
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux is not supported by firebase, and thus this app entirely'
        );
      default:
        throw UnsupportedError(
          'The platform you are trying to use this on is not supported.'
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs7Rpq6-wPzBD1xun40cgbBVMD6RR_u3s',
    appId: '1:1031401823307:web:dbc9d48d51a60e797581ce',
    messagingSenderId: '1031401823307',
    projectId: 'nuke-my-inbox',
    authDomain: 'nuke-my-inbox.firebaseapp.com',
    storageBucket: 'nuke-my-inbox.appspot.com',
    measurementId: 'G-CPKDK98L75',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaMaeSoycpTBaaPThOVvwwRK-uuCFaKhI',
    appId: '1:1031401823307:android:059c82c8487d48327581ce',
    messagingSenderId: '1031401823307',
    projectId: 'nuke-my-inbox',
    storageBucket: 'nuke-my-inbox.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKJ4hp_W8Rlx4IpAPrnilF35LzEUT-Bdk',
    appId: '1:1031401823307:ios:ad4115013e8aac0e7581ce',
    messagingSenderId: '1031401823307',
    projectId: 'nuke-my-inbox',
    storageBucket: 'nuke-my-inbox.appspot.com',
    androidClientId: '1031401823307-0pmfc65s2ohlc3an0fa7thgvn6gv3gvn.apps.googleusercontent.com',
    iosClientId: '1031401823307-nnuald2l89jpehervv54b96pcgre19uj.apps.googleusercontent.com',
    iosBundleId: 'com.example.nukeMyInbox',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKJ4hp_W8Rlx4IpAPrnilF35LzEUT-Bdk',
    appId: '1:1031401823307:ios:ad4115013e8aac0e7581ce',
    messagingSenderId: '1031401823307',
    projectId: 'nuke-my-inbox',
    storageBucket: 'nuke-my-inbox.appspot.com',
    androidClientId: '1031401823307-0pmfc65s2ohlc3an0fa7thgvn6gv3gvn.apps.googleusercontent.com',
    iosClientId: '1031401823307-nnuald2l89jpehervv54b96pcgre19uj.apps.googleusercontent.com',
    iosBundleId: 'com.example.nukeMyInbox',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBs7Rpq6-wPzBD1xun40cgbBVMD6RR_u3s',
    appId: '1:1031401823307:web:4b7592acab273d667581ce',
    messagingSenderId: '1031401823307',
    projectId: 'nuke-my-inbox',
    authDomain: 'nuke-my-inbox.firebaseapp.com',
    storageBucket: 'nuke-my-inbox.appspot.com',
    measurementId: 'G-KRSZQJ5KDV',
  );
}
