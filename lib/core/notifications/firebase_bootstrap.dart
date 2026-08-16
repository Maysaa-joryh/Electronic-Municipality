import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Owns the Firebase lifecycle for foreground and background FCM usage.
///
/// Initialization is started from `main` without waiting for it to draw the
/// first Flutter frame. Consumers must await [ensureInitialized] before using
/// a Firebase plugin, which prevents `[core/no-app]` failures.
class FirebaseBootstrap {
  FirebaseBootstrap._();

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
        await Firebase.initializeApp();
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
