import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import 'firebase_bootstrap.dart';

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

/// A locally retained record for the in-app notification centre.
class PushInboxItem {
  const PushInboxItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.intent,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final PushNotificationIntent? intent;
  final bool isRead;

  PushInboxItem copyWith({bool? isRead}) {
    return PushInboxItem(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      intent: intent,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'body': body,
      'received_at': receivedAt.toIso8601String(),
      'intent': intent == null ? null : jsonDecode(intent!.toPayload()),
      'is_read': isRead,
    };
  }

  static PushInboxItem? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final title = json['title']?.toString();
    final receivedAt = DateTime.tryParse(json['received_at']?.toString() ?? '');
    if (id == null || id.isEmpty || title == null || receivedAt == null) {
      return null;
    }

    final rawIntent = json['intent'];
    PushNotificationIntent? intent;
    if (rawIntent is Map) {
      intent = PushNotificationIntent.fromData(
        rawIntent.map(
          (key, dynamic value) => MapEntry(key.toString(), value),
        ),
      );
    }

    return PushInboxItem(
      id: id,
      title: title,
      body: json['body']?.toString() ?? '',
      receivedAt: receivedAt,
      intent: intent,
      isRead: json['is_read'] == true,
    );
  }
}

enum PushNotificationPermission {
  authorized,
  provisional,
  denied,
  notDetermined,
}

/// Keeps Laravel's registered device token in sync with Firebase Cloud Messaging.
class PushNotificationService {
  PushNotificationService({
    required ApiClient apiClient,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    FlutterSecureStorage? storage,
  })  : _apiClient = apiClient,
        _messaging = messaging,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _fcmTokenPath = 'devices/fcm-token';
  static const _channelId = 'municipality_status_updates';
  static const _channelName = 'تحديثات بلديتنا';
  static const _channelDescription =
      'إشعارات حالة المعاملات والشكاوى البلدية.';
  static const _inboxStorageKey = 'push_notification_inbox_v1';
  static const _maxInboxItems = 50;

  final ApiClient _apiClient;
  FirebaseMessaging? _messaging;

  FirebaseMessaging get _firebaseMessaging =>
      _messaging ??= FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FlutterSecureStorage _storage;
  final StreamController<PushNotificationIntent> _openedController =
      StreamController<PushNotificationIntent>.broadcast();
  final StreamController<PushNotificationMessage> _foregroundController =
      StreamController<PushNotificationMessage>.broadcast();
  final ValueNotifier<List<PushInboxItem>> _inbox =
      ValueNotifier<List<PushInboxItem>>(const <PushInboxItem>[]);

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  PushNotificationIntent? _initialIntent;
  Future<void>? _inboxLoading;
  Future<void>? _starting;
  bool _started = false;
  bool _localNotificationsInitialized = false;

  Stream<PushNotificationIntent> get opened => _openedController.stream;
  Stream<PushNotificationMessage> get foreground => _foregroundController.stream;
  ValueListenable<List<PushInboxItem>> get inbox => _inbox;
  int get unreadCount => _inbox.value.where((item) => !item.isRead).length;

  Future<void> start() {
    if (_started) return _resumeStartedService();

    final starting = _starting;
    if (starting != null) return starting;

    final operation = _startService();
    _starting = operation;
    return operation.whenComplete(() => _starting = null);
  }

  Future<void> _cancelMessageSubscriptions() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundSubscription = null;
    _openedSubscription = null;
  }

  Future<void> requestPermissionFromUser() async {
    await FirebaseBootstrap.ensureInitialized();
    await _initializeLocalNotifications();
    final settings = await _requestPermission();
    if (_isPermissionGranted(settings)) {
      await _syncCurrentToken();
    }
  }

  Future<PushNotificationPermission> getPermissionStatus() async {
    await FirebaseBootstrap.ensureInitialized();
    final settings = await _firebaseMessaging.getNotificationSettings();
    return _mapPermissionStatus(settings.authorizationStatus);
  }

  Future<void> markRead(String itemId) async {
    await _ensureInboxLoaded();
    final next = _inbox.value
        .map(
          (item) => item.id == itemId ? item.copyWith(isRead: true) : item,
        )
        .toList(growable: false);
    _inbox.value = next;
    await _persistInbox();
  }

  Future<void> markAllRead() async {
    await _ensureInboxLoaded();
    if (unreadCount == 0) return;
    _inbox.value = _inbox.value
        .map((item) => item.copyWith(isRead: true))
        .toList(growable: false);
    await _persistInbox();
  }

  /// Removes records belonging to the local session before another account uses
  /// the same device.
  Future<void> clearInbox() async {
    await _ensureInboxLoaded();
    _inbox.value = const <PushInboxItem>[];
    await _storage.delete(key: _inboxStorageKey);
  }

  Future<void> _resumeStartedService() async {
    await FirebaseBootstrap.ensureInitialized();
    await _ensureInboxLoaded();
    await _syncCurrentToken();
  }

  Future<void> _startService() async {
    try {
      await FirebaseBootstrap.ensureInitialized();
      debugPrint('FCM START: Firebase is ready.');

      await _ensureInboxLoaded();
      await _initializeLocalNotifications();

      // Attach all message listeners before token registration. A temporary
      // backend/API failure must never disable reception of an already valid
      // FCM token for the current app session.
      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen(
        (token) => unawaited(_registerTokenSafely(token)),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FCM TOKEN REFRESH ERROR: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        (message) => unawaited(_handleForegroundMessage(message)),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FCM FOREGROUND MESSAGE ERROR: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => unawaited(_emitOpenedIntent(message)),
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('FCM OPENED MESSAGE ERROR: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );

      final settings = await _requestPermission();
      final permissionGranted = _isPermissionGranted(settings);
      debugPrint(
        'FCM PERMISSION: ${settings.authorizationStatus} '
        '(granted=$permissionGranted).',
      );

      if (permissionGranted) {
        await _syncCurrentToken();
      } else {
        debugPrint('FCM TOKEN SYNC SKIPPED: notification permission is not granted.');
      }

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        await _recordRemoteMessage(initialMessage);
        _initialIntent = PushNotificationIntent.fromData(initialMessage.data);
      }

      _started = true;
      debugPrint('FCM STARTED: foreground and notification-open listeners are active.');
    } catch (_) {
      await _cancelMessageSubscriptions();
      rethrow;
    }
  }

  PushNotificationIntent? takeInitialIntent() {
    final intent = _initialIntent;
    _initialIntent = null;
    return intent;
  }

  Future<void> unregister() async {
    await FirebaseBootstrap.ensureInitialized();
    final token = await _firebaseMessaging.getToken();
    if (token == null || token.trim().isEmpty) return;

    await _apiClient.delete(
      _fcmTokenPath,
      data: <String, dynamic>{'fcm_token': token},
    );
  }

  Future<void> dispose() async {
    await _cancelMessageSubscriptions();
    await _openedController.close();
    await _foregroundController.close();
    _inbox.dispose();
  }

  Future<NotificationSettings> _requestPermission() {
    return _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _syncCurrentToken() async {
    // Explicitly keep automatic token generation enabled. The setting is
    // persistent on Android, so this also repairs devices that were disabled
    // during a previous development test.
    await _firebaseMessaging.setAutoInitEnabled(true);
    debugPrint('FCM TOKEN SYNC: requesting the current device token.');

    final token = await _firebaseMessaging.getToken();
    if (token == null || token.trim().isEmpty) {
      debugPrint('FCM TOKEN UNAVAILABLE: token was empty.');
      return;
    }
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
      debugPrint('FCM TOKEN REGISTERED: ${_redactedToken(token)}');
    } catch (error, stackTrace) {
      // Token registration must never block authentication or navigation, but
      // it must be observable while testing the central Laravel API.
      debugPrint('FCM TOKEN REGISTRATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localNotificationsInitialized) return;

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

    _localNotificationsInitialized = true;
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final content = await _recordRemoteMessage(message);
    _foregroundController.add(content);
    debugPrint('FCM FOREGROUND MESSAGE: ${message.messageId ?? 'without-id'}');

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
        content.title,
        content.body,
        details,
        payload: content.intent?.toPayload(),
      );
    } catch (error, stackTrace) {
      // Inbox persistence and its unread badge have already succeeded above.
      // A device-specific system-notification failure must not discard the
      // received municipal update.
      debugPrint('FCM LOCAL NOTIFICATION DISPLAY ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _emitOpenedIntent(RemoteMessage message) async {
    final content = await _recordRemoteMessage(message);
    if (content.intent != null) _openedController.add(content.intent!);
  }

  Future<PushNotificationMessage> _recordRemoteMessage(
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    final title = notification?.title?.trim();
    final body = notification?.body?.trim();
    final intent = PushNotificationIntent.fromData(message.data);
    final content = PushNotificationMessage(
      title: title == null || title.isEmpty ? 'بلديتنا' : title,
      body: body ?? '',
      intent: intent,
    );

    await _ensureInboxLoaded();
    final id = message.messageId?.trim();
    final itemId = id == null || id.isEmpty
        ? '${DateTime.now().microsecondsSinceEpoch}-${content.title.hashCode}'
        : id;
    if (_inbox.value.any((item) => item.id == itemId)) return content;

    final item = PushInboxItem(
      id: itemId,
      title: content.title,
      body: content.body,
      receivedAt: DateTime.now(),
      intent: intent,
      isRead: false,
    );
    _inbox.value = <PushInboxItem>[item, ..._inbox.value].take(_maxInboxItems).toList();
    await _persistInbox();
    return content;
  }

  Future<void> _ensureInboxLoaded() {
    final loading = _inboxLoading;
    if (loading != null) return loading;

    final operation = _loadInbox();
    _inboxLoading = operation;
    return operation;
  }

  Future<void> _loadInbox() async {
    try {
      final raw = await _storage.read(key: _inboxStorageKey);
      if (raw == null || raw.trim().isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      final items = decoded
          .whereType<Map>()
          .map(
            (value) => PushInboxItem.fromJson(
              value.map(
                (key, dynamic entry) => MapEntry(key.toString(), entry),
              ),
            ),
          )
          .whereType<PushInboxItem>()
          .toList()
        ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
      _inbox.value = List<PushInboxItem>.unmodifiable(items);
    } catch (error, stackTrace) {
      debugPrint('PUSH INBOX LOAD ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _persistInbox() async {
    try {
      final raw = jsonEncode(_inbox.value.map((item) => item.toJson()).toList());
      await _storage.write(key: _inboxStorageKey, value: raw);
    } catch (error, stackTrace) {
      debugPrint('PUSH INBOX SAVE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool _isPermissionGranted(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  PushNotificationPermission _mapPermissionStatus(
    AuthorizationStatus status,
  ) {
    return switch (status) {
      AuthorizationStatus.authorized => PushNotificationPermission.authorized,
      AuthorizationStatus.provisional => PushNotificationPermission.provisional,
      AuthorizationStatus.denied => PushNotificationPermission.denied,
      AuthorizationStatus.notDetermined =>
        PushNotificationPermission.notDetermined,
    };
  }

  String get _platformName {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  String _redactedToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}…${token.substring(token.length - 6)}';
  }
}
