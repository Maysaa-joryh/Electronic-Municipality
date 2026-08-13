import 'package:electronic_municipality/features/complaints/data/model/complaint_api_model.dart';

import 'complaints_mapper.dart';
import 'complaints_remote_data_source.dart';
import 'complaints_repository.dart';
import '../presentation/models/complaint_models.dart' as models;

class ComplaintsRepositoryApi implements ComplaintsRepository {
  ComplaintsRepositoryApi(
      {required ComplaintsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ComplaintsRemoteDataSource _remoteDataSource;

  @override
  Future<List<models.Complaint>> getComplaints() async {
    final items = await _remoteDataSource.getComplaints();
    return ComplaintsMapper.toUiComplaintList(items);
  }

  @override
  Future<models.Complaint> getComplaintById(int complaintId) async {
    final item = await _remoteDataSource.getComplaintById(complaintId);
    return ComplaintsMapper.toUiComplaint(item);
  }

  @override
  Future<void> deleteComplaint(int complaintId) {
    return _remoteDataSource.deleteComplaint(complaintId);
  }

  @override
  Future<models.Complaint> createAndSubmitComplaint(
    NewComplaintInput input,
  ) async {
    // 1) create the draft.
    final draft = await _remoteDataSource.createDraft(
      ComplaintDraftApiRequest(
        municipalityId: input.municipalityId,
        categoryId: input.categoryId,
        title: input.title,
        description: input.description,
        textLocation: input.textLocation,
        latitude: input.latitude,
        longitude: input.longitude,
      ),
    );

    // 2) upload attachments onto the draft, if any were picked.
    if (input.attachments.isNotEmpty) {
      await _remoteDataSource.uploadImages(
        draft.id,
        input.attachments
            .map(
              (a) => ComplaintImageUpload(fileName: a.fileName, bytes: a.bytes),
            )
            .toList(growable: false),
      );
    }

    // 3) finalize/submit the draft.
    final ComplaintApiModel submitted =
        await _remoteDataSource.submit(draft.id);

    return ComplaintsMapper.toUiComplaint(submitted);
  }
}
