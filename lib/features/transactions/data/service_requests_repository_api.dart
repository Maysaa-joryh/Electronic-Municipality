import 'dart:typed_data';

import '../domain/service_requests_repository.dart';
import 'models/service_request_models.dart';
import 'service_requests_remote_data_source.dart';

class ServiceRequestsRepositoryApi implements ServiceRequestsRepository {
  const ServiceRequestsRepositoryApi({required this.remoteDataSource});

  final ServiceRequestsRemoteDataSource remoteDataSource;

  @override
  Future<ServiceRequestPage<MunicipalServiceType>> getServices({
    int page = 1,
    int perPage = 50,
  }) {
    return remoteDataSource.getServices(page: page, perPage: perPage);
  }

  @override
  Future<MunicipalServiceType> getService(int serviceTypeId) {
    return remoteDataSource.getService(serviceTypeId);
  }

  @override
  Future<List<MunicipalServiceType>> getAllServices({int perPage = 50}) {
    return _allPages<MunicipalServiceType>(
      (page) => getServices(page: page, perPage: perPage),
    );
  }

  @override
  Future<ServiceRequestPage<MunicipalServiceRequest>> getRequests({
    int page = 1,
    int perPage = 50,
  }) {
    return remoteDataSource.getRequests(page: page, perPage: perPage);
  }

  @override
  Future<List<MunicipalServiceRequest>> getAllRequests({int perPage = 50}) {
    return _allPages<MunicipalServiceRequest>(
      (page) => getRequests(page: page, perPage: perPage),
    );
  }

  @override
  Future<MunicipalServiceRequest> getRequest(int requestId) {
    return remoteDataSource.getRequest(requestId);
  }

  @override
  Future<MunicipalServiceRequest> createDraft({
    required int serviceTypeVersionId,
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    return remoteDataSource.createDraft(
      serviceTypeVersionId: serviceTypeVersionId,
      data: data,
    );
  }

  @override
  Future<MunicipalServiceRequest> updateDraft({
    required int requestId,
    required Map<String, dynamic> data,
  }) {
    return remoteDataSource.updateDraft(requestId: requestId, data: data);
  }

  @override
  Future<void> deleteDraft(int requestId) {
    return remoteDataSource.deleteDraft(requestId);
  }

  @override
  Future<ServiceRequestAttachment> uploadAttachment({
    required int requestId,
    required String fieldKey,
    required ServiceRequestAttachmentInput attachment,
  }) {
    return remoteDataSource.uploadAttachment(
      requestId: requestId,
      fieldKey: fieldKey,
      attachment: attachment,
    );
  }

  @override
  Future<void> deleteAttachment({
    required int requestId,
    required int attachmentId,
  }) {
    return remoteDataSource.deleteAttachment(
      requestId: requestId,
      attachmentId: attachmentId,
    );
  }

  @override
  Future<Uint8List> downloadAttachment({
    required int requestId,
    required int attachmentId,
  }) {
    return remoteDataSource.downloadAttachment(
      requestId: requestId,
      attachmentId: attachmentId,
    );
  }

  @override
  Future<MunicipalServiceRequest> submitDraft(int requestId) {
    return remoteDataSource.submitDraft(requestId);
  }

  @override
  Future<Uint8List> downloadDocument(int requestId) {
    return remoteDataSource.downloadDocument(requestId);
  }

  Future<List<T>> _allPages<T>(
    Future<ServiceRequestPage<T>> Function(int page) loadPage,
  ) async {
    final results = <T>[];
    var page = 1;
    var previousPage = 0;
    while (true) {
      final response = await loadPage(page);
      results.addAll(response.items);
      if (!response.hasNextPage || response.currentPage <= previousPage) break;
      previousPage = response.currentPage;
      page = response.currentPage + 1;
    }
    return List<T>.unmodifiable(results);
  }
}
