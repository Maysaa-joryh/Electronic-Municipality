import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/notifications/firebase_bootstrap.dart';
import 'l10n/app_locale_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = AppLocaleController();
  final firebaseInitialization = FirebaseBootstrap.ensureInitialized();

  // Render Flutter immediately so the app's custom splash replaces Android's
  // launch window. FCM users still await this same shared initialization.
  runApp(AppRoot(localeController: localeController));

  unawaited(
    _initializeRuntimeServices(
      localeController: localeController,
      firebaseInitialization: firebaseInitialization,
    ),
  );
}

Future<void> _initializeRuntimeServices({
  required AppLocaleController localeController,
  required Future<void> firebaseInitialization,
}) async {
  await localeController.load();

  try {
    await firebaseInitialization;
  } catch (error, stackTrace) {
    // Firebase failures do not block the custom splash or the rest of the app.
    // The notification action retries the same bootstrap and shows its error.
    debugPrint('FIREBASE INITIALIZATION ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
