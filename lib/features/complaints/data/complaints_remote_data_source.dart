import 'package:dio/dio.dart';
import 'package:electronic_municipality/features/complaints/data/model/complaint_api_model.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';


/// Exact request contract required by Laravel's citizen complaint endpoints
/// (see `createComplaint` / `UpdateComplaint` in the Postman collection).
class ComplaintDraftApiRequest {
  const ComplaintDraftApiRequest({
    required this.municipalityId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.textLocation,
    required this.latitude,
    required this.longitude,
  });

  final int municipalityId;
  final int categoryId;
  final String title;
  final String description;
  final String textLocation;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toFormFields() {
    return <String, dynamic>{
      'municipality_id': municipalityId,
      'category_id': categoryId,
      'title': title.trim(),
      'description': description.trim(),
      'text_location': textLocation.trim(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ComplaintImageUpload {
  const ComplaintImageUpload({required this.fileName, required this.bytes});

  final String fileName;
  final List<int> bytes;
}

class ComplaintsRemoteDataSource {
  const ComplaintsRemoteDataSource(this._client);

  final ApiClient _client;

  /// GET /citizen/complaints — all complaints belonging to the logged-in citizen.
  Future<List<ComplaintApiModel>> getComplaints() async {
    final envelope = await _client.get(ApiEndpoints.citizenComplaints);
    return _requiredListData(envelope)
        .map(ComplaintApiModel.fromJson)
        .toList(growable: false);
  }

  /// GET /citizen/complaints/{id} — a single complaint's details.
  Future<ComplaintApiModel> getComplaintById(int complaintId) async {
    final envelope = await _client.get(
      ApiEndpoints.citizenComplaintById(complaintId),
    );
    return ComplaintApiModel.fromJson(_requiredData(envelope));
  }

  /// POST /citizen/complaints/drafts — step 1: create the complaint as a draft.
  Future<ComplaintApiModel> createDraft(
    ComplaintDraftApiRequest request,
  ) async {
    final envelope = await _client.post(
      ApiEndpoints.citizenComplaintDrafts,
      data: request.toFormFields(),
    );
    return ComplaintApiModel.fromJson(_requiredData(envelope));
  }

  /// PATCH /citizen/complaints/{id} — edit a complaint (usually while still a draft).
  Future<ComplaintApiModel> updateComplaint(
    int complaintId,
    ComplaintDraftApiRequest request,
  ) async {
    final envelope = await _client.patch(
      ApiEndpoints.citizenComplaintById(complaintId),
      data: request.toFormFields(),
    );
    return ComplaintApiModel.fromJson(_requiredData(envelope));
  }

  /// DELETE /citizen/complaints/{id}.
  Future<void> deleteComplaint(int complaintId) async {
    final envelope = await _client.delete(
      ApiEndpoints.citizenComplaintById(complaintId),
    );
    _validateSuccess(envelope);
  }

  /// POST /citizen/complaints/{id}/images — step 2: attach photos to the draft.
  /// [images] holds file name + bytes pairs, e.g. from `XFile.readAsBytes()`.
  Future<List<ComplaintImage>> uploadImages(
    int complaintId,
    List<ComplaintImageUpload> images,
  ) async {
    if (images.isEmpty) return const <ComplaintImage>[];

    final envelope = await _client.post(
      ApiEndpoints.citizenComplaintImages(complaintId),
      data: FormData.fromMap(<String, dynamic>{
        'images[]': images
            .map(
              (image) => MultipartFile.fromBytes(
                image.bytes,
                filename: _safeFileName(image.fileName),
              ),
            )
            .toList(growable: false),
      }),
    );

    final data = envelope['data'];
    if (data is Iterable) {
      return data
          .map((dynamic item) {
            if (item is Map<String, dynamic>) {
              return ComplaintImage.fromJson(item);
            }
            if (item is Map) {
              return ComplaintImage.fromJson(
                item.map((key, dynamic v) => MapEntry(key.toString(), v)),
              );
            }
            return null;
          })
          .whereType<ComplaintImage>()
          .toList(growable: false);
    }
    // Some Laravel endpoints just return {"success": true} with no images
    // payload; that's fine, the caller can re-fetch the complaint if needed.
    _validateSuccess(envelope);
    return const <ComplaintImage>[];
  }

  /// DELETE /citizen/complaints/{id}/images/{imageId}.
  Future<void> deleteImage(int complaintId, int imageId) async {
    final envelope = await _client.delete(
      ApiEndpoints.citizenComplaintImage(complaintId, imageId),
    );
    _validateSuccess(envelope);
  }

  /// POST /citizen/complaints/{id}/submit — step 3: finalize and submit the draft.
  Future<ComplaintApiModel> submit(int complaintId) async {
    final envelope = await _client.post(
      ApiEndpoints.citizenComplaintSubmit(complaintId),
    );
    return ComplaintApiModel.fromJson(_requiredData(envelope));
  }

  static String _safeFileName(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[/\\]'), '_');
    return normalized.isEmpty ? 'complaint-image.jpg' : normalized;
  }

  static Map<String, dynamic> _requiredData(Map<String, dynamic> envelope) {
    _validateSuccess(envelope);
    final data = _nullableMap(envelope['data']);
    if (data == null) {
      throw ApiException.invalidResponse(
        message: 'لم تتضمن استجابة الخادم بيانات الشكوى.',
      );
    }
    return data;
  }

  static List<Map<String, dynamic>> _requiredListData(
    Map<String, dynamic> envelope,
  ) {
    _validateSuccess(envelope);
    final data = envelope['data'];
    if (data is! Iterable) {
      throw ApiException.invalidResponse(
        message: 'لم تتضمن استجابة الخادم قائمة شكاوى صالحة.',
      );
    }

    try {
      return data.map((item) {
        final map = _nullableMap(item);
        if (map == null) throw const FormatException('Invalid list item.');
        return map;
      }).toList(growable: false);
    } on FormatException catch (error) {
      throw ApiException.invalidResponse(cause: error);
    }
  }

  static void _validateSuccess(Map<String, dynamic> envelope) {
    // Some Laravel controllers return {"success": true, ...} like the auth
    // endpoints; others (typical Laravel API Resource controllers) just
    // return the resource/collection directly with a 2xx status and no
    // "success" key. Treat "no explicit success key" as success too, since
    // ApiClient already throws on non-2xx responses.
    if (envelope['success'] == false) {
      final message = envelope['message']?.toString().trim();
      throw ApiException.invalidResponse(
        message: 'تعذر التحقق من استجابة الخادم.',
        technicalMessage: message == null || message.isEmpty
            ? envelope.toString()
            : message,
      );
    }
  }

  static Map<String, dynamic>? _nullableMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}
