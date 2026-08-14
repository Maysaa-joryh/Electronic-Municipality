import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/core/network/api_exception.dart';
import 'package:electronic_municipality/features/complaints/data/complaint_endpoints.dart';
import 'package:electronic_municipality/features/complaints/data/models/complaint_models.dart';

void main() {
  test('category model matches the authenticated hierarchical response', () {
    final category = ComplaintCategory.fromJson(
      <String, dynamic>{
        'id': 1,
        'parent_id': null,
        'name': 'الطرق والأرصفة',
        'children': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 2,
            'parent_id': 1,
            'name': 'حفرة في الطريق',
          },
        ],
      },
    );

    expect(category.id, 1);
    expect(category.parentId, isNull);
    expect(category.key, isNull);
    expect(category.name, 'الطرق والأرصفة');
    expect(category.isGroup, isTrue);
    expect(category.children, hasLength(1));
    expect(category.children.single.id, 2);
    expect(category.children.single.parentId, 1);
    expect(category.children.single.name, 'حفرة في الطريق');
    expect(ComplaintEndpoints.categories, 'ComplaintCategories');
  });

  test('draft request uses exactly the Laravel complaint field names', () {
    const input = ComplaintDraftInput(
      municipalityId: 12,
      categoryId: 2,
      title: '  انقطاع المياه  ',
      description: '  انقطاع منذ الصباح  ',
      textLocation: '  قرب الحديقة  ',
      latitude: 33.5138,
      longitude: 36.2765,
    );

    expect(
      input.toJson(),
      <String, dynamic>{
        'municipality_id': 12,
        'category_id': 2,
        'title': 'انقطاع المياه',
        'description': 'انقطاع منذ الصباح',
        'text_location': 'قرب الحديقة',
        'latitude': 33.5138,
        'longitude': 36.2765,
      },
    );
    expect(input.submissionErrors(), isEmpty);
  });

  test('submission validation reports the six backend-required fields', () {
    const input = ComplaintDraftInput();

    expect(
      input.submissionErrors().keys,
      <String>[
        'municipality_id',
        'category_id',
        'title',
        'description',
        'latitude',
        'longitude',
      ],
    );
  });

  test('can_edit from backend overrides draft fallback', () {
    final report = ComplaintReport.fromJson(
      <String, dynamic>{
        'id': 7,
        'status': <String, dynamic>{
          'key': 'draft',
          'label': 'مسودة',
        },
        'can_edit': false,
        'images': <Object>[],
      },
    );

    expect(report.status.isDraft, isTrue);
    expect(report.canEdit, isFalse);
  });

  test('report model matches detail response image and coordinate fields', () {
    final report = ComplaintReport.fromJson(
      <String, dynamic>{
        'id': 31,
        'title': 'حاوية ممتلئة',
        'latitude': '33.4730210',
        'longitude': '36.2496910',
        'status': <String, dynamic>{
          'id': 1,
          'key': 'draft',
          'name': 'مسودة',
        },
        'images': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 1,
            'original_name': 'evidence.jpg',
            'view_url': 'http://server/storage/evidence.jpg',
          },
        ],
      },
    );

    expect(report.latitude, 33.473021);
    expect(report.longitude, 36.249691);
    expect(report.status.label, 'مسودة');
    expect(report.images.single.name, 'evidence.jpg');
    expect(
      report.images.single.url,
      'http://server/storage/evidence.jpg',
    );
  });

  test('draft status is fallback when can_edit is absent', () {
    final report = ComplaintReport.fromJson(
      <String, dynamic>{
        'id': 8,
        'status': <String, dynamic>{
          'key': 'draft',
          'label': 'مسودة',
        },
        'images': <Object>[],
      },
    );

    expect(report.canEdit, isTrue);
  });

  test('complaint images are limited to five JPG or PNG files', () {
    final valid = ComplaintAttachment(
      name: 'evidence.JPG',
      bytes: Uint8List(10),
    );

    expect(
      () => ComplaintAttachment.validateSelection(
        <ComplaintAttachment>[valid],
        existingCount: 4,
      ),
      returnsNormally,
    );
    expect(
      () => ComplaintAttachment.validateSelection(
        <ComplaintAttachment>[valid, valid],
        existingCount: 4,
      ),
      throwsA(isA<ApiException>()),
    );
    expect(
      () => ComplaintAttachment.validateSelection(
        <ComplaintAttachment>[
          ComplaintAttachment(name: 'file.pdf', bytes: Uint8List(10)),
        ],
      ),
      throwsA(isA<ApiException>()),
    );
  });

  test('maps complaint validation fields to safe Arabic messages', () {
    final requestOptions = RequestOptions(
      path: 'citizen/complaints/drafts',
    );
    final dioError = DioException(
      requestOptions: requestOptions,
      response: Response<Map<String, dynamic>>(
        requestOptions: requestOptions,
        statusCode: 422,
        data: <String, dynamic>{
          'message': 'The given data was invalid.',
          'errors': <String, dynamic>{
            'category_id': <String>['The category id field is required.'],
          },
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final error = ApiException.fromDioException(dioError);

    expect(error.message, 'حقل تصنيف الشكوى مطلوب.');
    expect(error.errorFor('category_id'), 'حقل تصنيف الشكوى مطلوب.');
  });

  test('maps unverified citizen rule without treating before as a date', () {
    final requestOptions = RequestOptions(
      path: 'citizen/complaints/32/submit',
    );
    final dioError = DioException(
      requestOptions: requestOptions,
      response: Response<Map<String, dynamic>>(
        requestOptions: requestOptions,
        statusCode: 422,
        data: <String, dynamic>{
          'message':
              'The citizen account must be verified before submitting a complaint.',
          'errors': <String, dynamic>{
            'citizen': <String>[
              'The citizen account must be verified before submitting a complaint.',
            ],
          },
        },
      ),
      type: DioExceptionType.badResponse,
    );

    final error = ApiException.fromDioException(dioError);

    expect(
      error.message,
      'حساب المواطن غير موثق. يجب توثيق الحساب قبل إرسال الشكوى.',
    );
    expect(error.requiresCitizenVerification, isTrue);
  });

  test('complaint endpoint paths preserve the draft workflow', () {
    expect(ComplaintEndpoints.drafts, 'citizen/complaints/drafts');
    expect(ComplaintEndpoints.report(9), 'citizen/complaints/9');
    expect(ComplaintEndpoints.images(9), 'citizen/complaints/9/images');
    expect(
      ComplaintEndpoints.image(9, 3),
      'citizen/complaints/9/images/3',
    );
    expect(ComplaintEndpoints.submit(9), 'citizen/complaints/9/submit');
  });
}
