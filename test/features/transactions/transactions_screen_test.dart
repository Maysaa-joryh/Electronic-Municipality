import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/core/repositories/auth_repository.dart';
import 'package:electronic_municipality/features/authentication/data/auth_repository_fake.dart';
import 'package:electronic_municipality/features/transactions/data/models/service_request_models.dart';
import 'package:electronic_municipality/features/transactions/domain/service_requests_repository.dart';
import 'package:electronic_municipality/features/transactions/presentation/screens/transactions_screen.dart';

void main() {
  testWidgets('shows verification notice for an unverified citizen', (
    WidgetTester tester,
  ) async {
    final authRepository = AuthRepositoryFake(
      currentUser: const AuthUser(
        id: 1,
        fullName: 'مواطن غير موثق',
        email: 'citizen@example.sy',
        phoneNumber: '0990000000',
        roles: <String>['citizen'],
        accountType: 'citizen',
        citizenProfile: <String, dynamic>{'is_verified': false},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionsScreen(
            authRepository: authRepository,
            repository: _FakeServiceRequestsRepository(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('citizen_verification_notice')),
      findsOneWidget,
    );
    expect(find.text('حساب المواطن غير موثق'), findsOneWidget);
  });

  testWidgets('transactions loads a citizen request and opens its details',
      (WidgetTester tester) async {
    final repository = _FakeServiceRequestsRepository();
    final auth = AuthRepositoryFake(currentUser: _verifiedCitizen);

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionsScreen(
          repository: repository,
          authRepository: auth,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('طلب رخصة بناء'), findsOneWidget);
    expect(find.text('رقم المعاملة #42'), findsOneWidget);
    expect(find.text('مسودة'), findsOneWidget);

    await tester.tap(find.text('طلب رخصة بناء'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('تفاصيل المعاملة'), findsOneWidget);
    expect(find.text('بيانات المعاملة'), findsOneWidget);
    expect(find.text('اسم المالك'), findsOneWidget);
    expect(find.text('محمد أحمد'), findsOneWidget);
  });
}

const AuthUser _verifiedCitizen = AuthUser(
  id: 42,
  fullName: 'مستخدم موثق',
  email: 'verified@example.sy',
  phoneNumber: '0990000000',
  roles: <String>['citizen'],
  accountType: 'citizen',
  citizenProfile: <String, dynamic>{
    'national_id': '11111111111',
    'is_verified': true,
  },
);

class _FakeServiceRequestsRepository implements ServiceRequestsRepository {
  final _service = MunicipalServiceType.fromJson(<String, dynamic>{
    'id': 8,
    'name': 'طلب رخصة بناء',
    'description': 'إصدار رخصة بناء إلكترونيًا.',
    'is_active': true,
    'municipality': <String, dynamic>{'id': 1, 'name': 'بلدية كفرسوسة'},
    'active_version': <String, dynamic>{
      'id': 15,
      'version_number': 1,
      'is_active': true,
      'fields': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 1,
          'field_key': 'owner_name',
          'label': 'اسم المالك',
          'field_type': 'text',
          'is_required': true,
          'options_json': <Object>[],
          'validation_json': <Object>[],
          'condition_json': null,
          'sort_order': 1,
        },
      ],
    },
  });

  late final MunicipalServiceRequest _request = MunicipalServiceRequest.fromJson(
    <String, dynamic>{
      'id': 42,
      'service_type': <String, dynamic>{
        'id': 8,
        'name': 'طلب رخصة بناء',
        'municipality': <String, dynamic>{'name': 'بلدية كفرسوسة'},
      },
      'data': <String, dynamic>{'owner_name': 'محمد أحمد'},
      'current_status': <String, dynamic>{
        'id': 1,
        'code': 'draft',
        'name': 'Draft',
        'name_ar': 'مسودة',
        'is_terminal': false,
      },
      'attachments': <Object>[],
      'submitted_at': null,
      'document': null,
      'created_at': '2026-08-15T09:00:00.000000Z',
      'updated_at': '2026-08-15T09:00:00.000000Z',
    },
  );

  @override
  Future<MunicipalServiceRequest> createDraft({
    required int serviceTypeVersionId,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async => _request;

  @override
  Future<void> deleteAttachment({
    required int requestId,
    required int attachmentId,
  }) async {}

  @override
  Future<void> deleteDraft(int requestId) async {}

  @override
  Future<Uint8List> downloadAttachment({
    required int requestId,
    required int attachmentId,
  }) async => Uint8List(0);

  @override
  Future<Uint8List> downloadDocument(int requestId) async => Uint8List(0);

  @override
  Future<MunicipalServiceType> getService(int serviceTypeId) async => _service;

  @override
  Future<ServiceRequestPage<MunicipalServiceType>> getServices({
    int page = 1,
    int perPage = 50,
  }) async => ServiceRequestPage<MunicipalServiceType>(
        items: <MunicipalServiceType>[_service],
        currentPage: 1,
        lastPage: 1,
        perPage: 50,
        total: 1,
      );

  @override
  Future<MunicipalServiceRequest> getRequest(int requestId) async => _request;

  @override
  Future<List<MunicipalServiceType>> getAllServices({int perPage = 50}) async =>
      <MunicipalServiceType>[_service];

  @override
  Future<ServiceRequestPage<MunicipalServiceRequest>> getRequests({
    int page = 1,
    int perPage = 50,
  }) async => ServiceRequestPage<MunicipalServiceRequest>(
        items: <MunicipalServiceRequest>[_request],
        currentPage: 1,
        lastPage: 1,
        perPage: 50,
        total: 1,
      );

  @override
  Future<List<MunicipalServiceRequest>> getAllRequests({int perPage = 50}) async =>
      <MunicipalServiceRequest>[_request];

  @override
  Future<MunicipalServiceRequest> submitDraft(int requestId) async => _request;

  @override
  Future<MunicipalServiceRequest> updateDraft({
    required int requestId,
    required Map<String, dynamic> data,
  }) async => _request;

  @override
  Future<ServiceRequestAttachment> uploadAttachment({
    required int requestId,
    required String fieldKey,
    required ServiceRequestAttachmentInput attachment,
  }) async => ServiceRequestAttachment(
        id: 1,
        fieldKey: fieldKey,
        originalName: attachment.name,
        mimeType: 'application/pdf',
        fileSize: attachment.bytes.length,
        createdAt: DateTime.now(),
      );
}
