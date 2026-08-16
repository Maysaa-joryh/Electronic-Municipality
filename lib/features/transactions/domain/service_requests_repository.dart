import 'dart:typed_data';

import '../data/models/service_request_models.dart';

abstract class ServiceRequestsRepository {
  Future<ServiceRequestPage<MunicipalServiceType>> getServices({
    int page = 1,
    int perPage = 50,
  });

  Future<MunicipalServiceType> getService(int serviceTypeId);

  Future<List<MunicipalServiceType>> getAllServices({int perPage = 50});

  Future<ServiceRequestPage<MunicipalServiceRequest>> getRequests({
    int page = 1,
    int perPage = 50,
  });

  Future<List<MunicipalServiceRequest>> getAllRequests({int perPage = 50});

  Future<MunicipalServiceRequest> getRequest(int requestId);

  Future<MunicipalServiceRequest> createDraft({
    required int serviceTypeVersionId,
    Map<String, dynamic> data = const <String, dynamic>{},
  });

  Future<MunicipalServiceRequest> updateDraft({
    required int requestId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDraft(int requestId);

  Future<ServiceRequestAttachment> uploadAttachment({
    required int requestId,
    required String fieldKey,
    required ServiceRequestAttachmentInput attachment,
  });

  Future<void> deleteAttachment({
    required int requestId,
    required int attachmentId,
  });

  Future<Uint8List> downloadAttachment({
    required int requestId,
    required int attachmentId,
  });

  Future<MunicipalServiceRequest> submitDraft(int requestId);

  Future<Uint8List> downloadDocument(int requestId);
}
