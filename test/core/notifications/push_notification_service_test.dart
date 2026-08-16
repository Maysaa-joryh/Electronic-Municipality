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
  });
}
