import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Owns the Firebase lifecycle for foreground and background FCM usage.
///
/// Initialization is started from `main` without waiting for it to draw the
/// first Flutter frame. Consumers must await [ensureInitialized] before using
/// a Firebase plugin, which prevents `[core/no-app]` failures.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  // Android's configuration is kept explicit as a resilience layer for the
  // Flutter 3.13 / Firebase Core 2.x stack. It exactly mirrors the public,
  // non-secret identifiers in android/app/google-services.json and prevents
  // Firebase.initializeApp from depending on a missing generated resource.
  static const FirebaseOptions _androidOptions = FirebaseOptions(
    apiKey: 'AIzaSyC-KQ0c7g4UqjsxqHYXXiUq11zwR87sNSc',
    appId: '1:449480767594:android:10a61a15f32332165a7213',
    messagingSenderId: '449480767594',
    projectId: 'municipality-mobile',
    storageBucket: 'municipality-mobile.firebasestorage.app',
  );

  static Future<void>? _initialization;
  static bool _backgroundHandlerRegistered = false;

  static Future<void> ensureInitialized() {
    final pending = _initialization;
    if (pending != null) return pending;

    final initialization = _initialize();
    _initialization = initialization;
    return initialization;
  }

  static Future<void> _initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: Platform.isAndroid ? _androidOptions : null,
        );
      }

      if (!_backgroundHandlerRegistered) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
        _backgroundHandlerRegistered = true;
      }
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseBootstrap.ensureInitialized();
}
