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
    apiKey: 'AIzaSyBPlFZh8e3MG7VW-4cNILDh0ejUm1ajzy0',
    appId: '1:877824353965:web:5b5b7beee247a28093c824',
    messagingSenderId: '877824353965',
    projectId: 'my-fashion-store-project',
    authDomain: 'my-fashion-store-project.firebaseapp.com',
    storageBucket: 'my-fashion-store-project.firebasestorage.app',
    measurementId: 'G-BXE238CTK1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBAKWQtM9OjdEswW_taQNbwG88NRgvPBhw',
    appId: '1:877824353965:android:9eafd0cf61abc04293c824',
    messagingSenderId: '877824353965',
    projectId: 'my-fashion-store-project',
    storageBucket: 'my-fashion-store-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUERlKFWqck9LZ16A4_4V7ZXtj5FTFDPs',
    appId: '1:877824353965:ios:911ac83f26dc082e93c824',
    messagingSenderId: '877824353965',
    projectId: 'my-fashion-store-project',
    storageBucket: 'my-fashion-store-project.firebasestorage.app',
    iosBundleId: 'com.example.fashionApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUERlKFWqck9LZ16A4_4V7ZXtj5FTFDPs',
    appId: '1:877824353965:ios:911ac83f26dc082e93c824',
    messagingSenderId: '877824353965',
    projectId: 'my-fashion-store-project',
    storageBucket: 'my-fashion-store-project.firebasestorage.app',
    iosBundleId: 'com.example.fashionApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBPlFZh8e3MG7VW-4cNILDh0ejUm1ajzy0',
    appId: '1:877824353965:web:59719f0beea5c2ed93c824',
    messagingSenderId: '877824353965',
    projectId: 'my-fashion-store-project',
    authDomain: 'my-fashion-store-project.firebaseapp.com',
    storageBucket: 'my-fashion-store-project.firebasestorage.app',
    measurementId: 'G-VL10XV8984',
  );
}
