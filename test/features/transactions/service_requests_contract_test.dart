import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/features/transactions/data/models/service_request_models.dart';
import 'package:electronic_municipality/features/transactions/data/service_request_endpoints.dart';

void main() {
  test('service catalog model parses the active dynamic form version', () {
    final service = MunicipalServiceType.fromJson(<String, dynamic>{
      'id': 12,
      'name': 'طلب رخصة بناء',
      'description': 'طلب إلكتروني للحصول على رخصة بناء.',
      'document_template_key': 'building-permit',
      'is_active': true,
      'municipality': <String, dynamic>{'id': 4, 'name': 'بلدية كفرسوسة'},
      'active_version': <String, dynamic>{
        'id': 33,
        'version_number': 2,
        'is_active': true,
        'fields': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'field_key': 'owner_name',
            'label': 'اسم المالك',
            'field_type': 'text',
            'is_required': true,
            'options_json': <Object>[],
            'validation_json': <String>['max:100'],
            'condition_json': null,
            'sort_order': 2,
          },
          <String, dynamic>{
            'id': 2,
            'field_key': 'ownership_deed',
            'label': 'صورة السند',
            'field_type': 'file',
            'is_required': true,
            'options_json': <Object>[],
            'validation_json': <Object>[],
            'condition_json': null,
            'sort_order': 1,
          },
        ],
      },
    });

    expect(service.id, 12);
    expect(service.municipalityName, 'بلدية كفرسوسة');
    expect(service.activeVersion?.id, 33);
    expect(service.activeVersion?.fields.first.fieldKey, 'ownership_deed');
    expect(service.activeVersion?.fields.first.isFile, isTrue);
    expect(service.activeVersion?.fields.last.validationRules, <String>['max:100']);
  });

  test('service request model parses current status, attachments and issued document', () {
    final request = MunicipalServiceRequest.fromJson(<String, dynamic>{
      'id': 48,
      'service_type': <String, dynamic>{
        'id': 12,
        'name': 'طلب رخصة بناء',
        'municipality': <String, dynamic>{'name': 'بلدية كفرسوسة'},
      },
      'data': <String, dynamic>{'owner_name': 'محمد أحمد', 'floors': '3'},
      'current_status': <String, dynamic>{
        'id': 4,
        'code': 'approved_and_document_issued',
        'name': 'Approved and document issued',
        'name_ar': 'تمت الموافقة وإصدار الوثيقة',
        'is_terminal': true,
      },
      'attachments': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 9,
          'field_key': 'ownership_deed',
          'original_name': 'deed.pdf',
          'mime_type': 'application/pdf',
          'file_size': 2048,
          'created_at': '2026-08-15T10:00:00.000000Z',
        },
      ],
      'submitted_at': '2026-08-15T10:01:00.000000Z',
      'document': <String, dynamic>{
        'id': 6,
        'document_number': 'DOC-2026-48',
        'verification_code': 'ABC123',
        'issued_at': '2026-08-15T11:00:00.000000Z',
        'expires_at': null,
        'is_expired': false,
        'is_signed': true,
      },
      'created_at': '2026-08-15T09:00:00.000000Z',
      'updated_at': '2026-08-15T11:00:00.000000Z',
    });

    expect(request.id, 48);
    expect(request.serviceType?.municipalityName, 'بلدية كفرسوسة');
    expect(request.status?.displayName, 'تمت الموافقة وإصدار الوثيقة');
    expect(request.status?.isTerminal, isTrue);
    expect(request.attachments.single.fieldKey, 'ownership_deed');
    expect(request.document?.documentNumber, 'DOC-2026-48');
    expect(request.hasIssuedDocument, isTrue);
  });

  test('citizen service request endpoint paths match Laravel routes', () {
    expect(ServiceRequestEndpoints.services, 'citizen/services');
    expect(ServiceRequestEndpoints.service(12), 'citizen/services/12');
    expect(ServiceRequestEndpoints.requests, 'citizen/service-requests');
    expect(ServiceRequestEndpoints.drafts, 'citizen/service-requests/drafts');
    expect(ServiceRequestEndpoints.request(48), 'citizen/service-requests/48');
    expect(
      ServiceRequestEndpoints.attachments(48),
      'citizen/service-requests/48/attachments',
    );
    expect(
      ServiceRequestEndpoints.attachment(48, 9),
      'citizen/service-requests/48/attachments/9',
    );
    expect(
      ServiceRequestEndpoints.submit(48),
      'citizen/service-requests/48/submit',
    );
    expect(
      ServiceRequestEndpoints.document(48),
      'citizen/service-requests/48/document',
    );
  });
}
