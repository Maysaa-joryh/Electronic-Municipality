import 'package:electronic_municipality/core/notifications/push_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNotificationIntent', () {
    test('maps a service-request payload to its integer identifier', () {
      final intent = PushNotificationIntent.fromData(const <String, dynamic>{
        'type': 'service_request',
        'id': '42',
        'status': 'pending_mayor_approval',
      });

      expect(intent, isNotNull);
      expect(intent!.opensServiceRequest, isTrue);
      expect(intent.entityId, 42);
      expect(intent.status, 'pending_mayor_approval');
    });

    test('round-trips a local foreground notification payload', () {
      const original = PushNotificationIntent(
        type: 'service_request',
        entityId: 7,
        status: 'approved_and_document_issued',
      );

      final decoded = PushNotificationIntent.fromPayload(original.toPayload());

      expect(decoded, isNotNull);
      expect(decoded!.type, original.type);
      expect(decoded.entityId, original.entityId);
      expect(decoded.status, original.status);
    });

    test('ignores payloads without a notification type', () {
      expect(
        PushNotificationIntent.fromData(const <String, dynamic>{'id': '7'}),
        isNull,
      );
    });

    test('round-trips a locally stored notification centre item', () {
      const intent = PushNotificationIntent(
        type: 'service_request',
        entityId: 11,
        status: 'pending_review',
      );
      final original = PushInboxItem(
        id: 'message-11',
        title: 'تحديث معاملة',
        body: 'تمت إحالة معاملتك للمراجعة.',
        receivedAt: DateTime.utc(2026, 8, 16, 10, 30),
        intent: intent,
        isRead: false,
      );

      final decoded = PushInboxItem.fromJson(original.toJson());

      expect(decoded, isNotNull);
      expect(decoded!.id, original.id);
      expect(decoded.intent?.entityId, 11);
      expect(decoded.isRead, isFalse);
    });
  });
}
