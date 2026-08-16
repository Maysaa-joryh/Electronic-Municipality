import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/api_client.dart';

/// Payload used to route a notification tap inside the authenticated app.
class PushNotificationIntent {
  const PushNotificationIntent({
    required this.type,
    required this.entityId,
    required this.status,
  });

  final String type;
  final int? entityId;
  final String? status;

  bool get opensServiceRequest =>
      type == 'service_request' || type == 'service-request';

  String toPayload() {
    return jsonEncode(<String, dynamic>{
      'type': type,
      'id': entityId?.toString(),
      'status': status,
    });
  }

  static PushNotificationIntent? fromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;
      return fromData(
        decoded.map(
          (key, dynamic value) => MapEntry(key.toString(), value),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static PushNotificationIntent? fromData(Map<String, dynamic> data) {
    final type = data['type']?.toString().trim();
    if (type == null || type.isEmpty) return null;

    final rawId = data['id']?.toString().trim();
    return PushNotificationIntent(
      type: type,
      entityId: rawId == null || rawId.isEmpty ? null : int.tryParse(rawId),
      status: data['status']?.toString().trim(),
    );
  }
}

/// Foreground content received from FCM and mirrored in a local notification.
class PushNotificationMessage {
  const PushNotificationMessage({
    required this.title,
    required this.body,
    required this.intent,
  });

  final String title;
  final String body;
  final PushNotificationIntent? intent;
}

/// Keeps Laravel's registered device token in sync with Firebase Cloud Messaging.
class PushNotificationService {
  PushNotificationService({
    required ApiClient apiClient,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _apiClient = apiClient,
        _messaging = messaging,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  static const _fcmTokenPath = 'devices/fcm-token';
  static const _channelId = 'municipality_status_updates';
  static const _channelName = 'تحديثات بلديتنا';
  static const _channelDescription =
      'إشعارات حالة المعاملات والشكاوى البلدية.';

  final ApiClient _apiClient;
  FirebaseMessaging? _messaging;

  FirebaseMessaging get _firebaseMessaging =>
      _messaging ??= FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<PushNotificationIntent> _openedController =
      StreamController<PushNotificationIntent>.broadcast();
  final StreamController<PushNotificationMessage> _foregroundController =
      StreamController<PushNotificationMessage>.broadcast();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  PushNotificationIntent? _initialIntent;
  bool _started = false;

  Stream<PushNotificationIntent> get opened => _openedController.stream;
  Stream<PushNotificationMessage> get foreground => _foregroundController.stream;

  Future<void> start() async {
    if (_started) {
      await _syncCurrentToken();
      return;
    }
    _started = true;

    await _initializeLocalNotifications();
    await _requestPermission();
    await _syncCurrentToken();

    _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
      _registerTokenSafely,
      onError: (_) {},
    );
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
      onError: (_) {},
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _emitOpenedIntent,
      onError: (_) {},
    );

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _initialIntent = PushNotificationIntent.fromData(initialMessage.data);
    }
  }

  PushNotificationIntent? takeInitialIntent() {
    final intent = _initialIntent;
    _initialIntent = null;
    return intent;
  }

  Future<void> unregister() async {
    final token = await _firebaseMessaging.getToken();
    if (token == null || token.trim().isEmpty) return;

    await _apiClient.delete(
      _fcmTokenPath,
      data: <String, dynamic>{'fcm_token': token},
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _openedController.close();
    await _foregroundController.close();
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _syncCurrentToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token == null || token.trim().isEmpty) return;
    await _registerTokenSafely(token);
  }

  Future<void> _registerTokenSafely(String token) async {
    try {
      await _apiClient.put(
        _fcmTokenPath,
        data: <String, dynamic>{
          'fcm_token': token,
          'platform': _platformName,
        },
      );
    } catch (_) {
      // Push registration must never block authentication or app navigation.
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final intent = PushNotificationIntent.fromPayload(response.payload);
        if (intent != null) _openedController.add(intent);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title?.trim();
    final body = notification?.body?.trim();
    final intent = PushNotificationIntent.fromData(message.data);

    final content = PushNotificationMessage(
      title: title == null || title.isEmpty ? 'بلديتنا' : title,
      body: body ?? '',
      intent: intent,
    );
    _foregroundController.add(content);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      content.title,
      content.body,
      details,
      payload: intent?.toPayload(),
    );
  }

  void _emitOpenedIntent(RemoteMessage message) {
    final intent = PushNotificationIntent.fromData(message.data);
    if (intent != null) _openedController.add(intent);
  }

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }
}
