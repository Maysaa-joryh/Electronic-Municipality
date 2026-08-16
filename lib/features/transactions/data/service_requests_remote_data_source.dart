import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'models/service_request_models.dart';
import 'service_request_endpoints.dart';

class ServiceRequestsRemoteDataSource {
  const ServiceRequestsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ServiceRequestPage<MunicipalServiceType>> getServices({
    required int page,
    required int perPage,
  }) async {
    final envelope = await _client.get(
      ServiceRequestEndpoints.services,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
      },
    );
    try {
      final data = _successfulData(envelope);
      return _pageFromData(
        data,
        MunicipalServiceType.fromJson,
      );
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MunicipalServiceType> getService(int serviceTypeId) async {
    final envelope = await _client.get(
      ServiceRequestEndpoints.service(serviceTypeId),
    );
    try {
      return MunicipalServiceType.fromJson(_requiredMap(_successfulData(envelope)));
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<ServiceRequestPage<MunicipalServiceRequest>> getRequests({
    required int page,
    required int perPage,
  }) async {
    final envelope = await _client.get(
      ServiceRequestEndpoints.requests,
      queryParameters: <String, dynamic>{
        'page': page,
        'per_page': perPage,
      },
    );
    try {
      return _pageFromData(
        _successfulData(envelope),
        MunicipalServiceRequest.fromJson,
      );
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<MunicipalServiceRequest> getRequest(int requestId) async {
    final envelope = await _client.get(ServiceRequestEndpoints.request(requestId));
    return _requestFromEnvelope(envelope);
  }

  Future<MunicipalServiceRequest> createDraft({
    required int serviceTypeVersionId,
    required Map<String, dynamic> data,
  }) async {
    final envelope = await _client.post(
      ServiceRequestEndpoints.drafts,
      data: <String, dynamic>{
        'service_type_version_id': serviceTypeVersionId,
        'data': data,
      },
    );
    return _requestFromEnvelope(envelope);
  }

  Future<MunicipalServiceRequest> updateDraft({
    required int requestId,
    required Map<String, dynamic> data,
  }) async {
    final envelope = await _client.patch(
      ServiceRequestEndpoints.request(requestId),
      data: <String, dynamic>{'data': data},
    );
    return _requestFromEnvelope(envelope);
  }

  Future<void> deleteDraft(int requestId) async {
    final envelope = await _client.delete(ServiceRequestEndpoints.request(requestId));
    _validateSuccess(envelope);
  }

  Future<ServiceRequestAttachment> uploadAttachment({
    required int requestId,
    required String fieldKey,
    required ServiceRequestAttachmentInput attachment,
  }) async {
    final envelope = await _client.post(
      ServiceRequestEndpoints.attachments(requestId),
      data: FormData.fromMap(<String, dynamic>{
        'field_key': fieldKey,
        'file': MultipartFile.fromBytes(
          attachment.bytes,
          filename: _safeFileName(attachment.name),
        ),
      }),
    );
    try {
      return ServiceRequestAttachment.fromJson(
        _requiredMap(_successfulData(envelope)),
      );
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  Future<void> deleteAttachment({
    required int requestId,
    required int attachmentId,
  }) async {
    final envelope = await _client.delete(
      ServiceRequestEndpoints.attachment(requestId, attachmentId),
    );
    _validateSuccess(envelope);
  }

  Future<Uint8List> downloadAttachment({
    required int requestId,
    required int attachmentId,
  }) {
    return _client.getBytes(
      ServiceRequestEndpoints.attachment(requestId, attachmentId),
    );
  }

  Future<MunicipalServiceRequest> submitDraft(int requestId) async {
    final envelope = await _client.post(ServiceRequestEndpoints.submit(requestId));
    return _requestFromEnvelope(envelope);
  }

  Future<Uint8List> downloadDocument(int requestId) {
    return _client.getBytes(ServiceRequestEndpoints.document(requestId));
  }

  static MunicipalServiceRequest _requestFromEnvelope(
    Map<String, dynamic> envelope,
  ) {
    try {
      return MunicipalServiceRequest.fromJson(
        _requiredMap(_successfulData(envelope)),
      );
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  static ServiceRequestPage<T> _pageFromData<T>(
    Object? data,
    T Function(Map<String, dynamic> json) mapper,
  ) {
    final dataMap = _requiredMap(data);
    final items = _requiredMapList(dataMap['items']).map(mapper).toList(growable: false);
    final pagination = _requiredMap(dataMap['pagination']);
    return ServiceRequestPage<T>(
      items: items,
      currentPage: _int(pagination['current_page'], fallback: 1),
      lastPage: _int(pagination['last_page'], fallback: 1),
      perPage: _int(pagination['per_page'], fallback: items.length),
      total: _int(pagination['total'], fallback: items.length),
    );
  }

  static Object? _successfulData(Map<String, dynamic> envelope) {
    _validateSuccess(envelope);
    if (!envelope.containsKey('data')) {
      throw const FormatException('Missing data in service request response.');
    }
    return envelope['data'];
  }

  static void _validateSuccess(Map<String, dynamic> envelope) {
    if (envelope['success'] == true) return;
    throw ApiException.invalidResponse(technicalMessage: envelope.toString());
  }

  static Map<String, dynamic> _requiredMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    throw const FormatException('Expected an object in service request response.');
  }

  static List<Map<String, dynamic>> _requiredMapList(Object? value) {
    if (value is! Iterable) {
      throw const FormatException('Expected a list in service request response.');
    }
    return value.map(_requiredMap).toList(growable: false);
  }

  static int _int(Object? value, {required int fallback}) {
    return switch (value) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  static String _safeFileName(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[/\\]'), '_');
    return normalized.isEmpty ? 'service-request-attachment' : normalized;
  }
}
