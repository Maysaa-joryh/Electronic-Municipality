import 'dart:typed_data';

import '../presentation/models/complaint_models.dart' as models;

class NewComplaintAttachment {
  const NewComplaintAttachment({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class NewComplaintInput {
  const NewComplaintInput({
    required this.municipalityId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.textLocation,
    required this.latitude,
    required this.longitude,
    this.attachments = const <NewComplaintAttachment>[],
  });

  final int municipalityId;
  final int categoryId;
  final String title;
  final String description;
  final String textLocation;
  final double latitude;
  final double longitude;
  final List<NewComplaintAttachment> attachments;
}

/// Contract for reading/writing citizen complaints. Implemented by
/// [ComplaintsRepositoryApi] against the Laravel backend; a fake/in-memory
/// implementation can be swapped in for widget tests the same way
/// `AuthRepositoryFake` is used for authentication.
abstract class ComplaintsRepository {
  /// Loads every complaint that belongs to the signed-in citizen.
  Future<List<models.Complaint>> getComplaints();

  /// Loads a single complaint's full details (used for refreshing one card).
  Future<models.Complaint> getComplaintById(int complaintId);

  /// Full create flow: draft -> upload attachments -> submit.
  /// Returns the final, submitted complaint.
  Future<models.Complaint> createAndSubmitComplaint(NewComplaintInput input);

  /// Deletes a complaint (only meaningful while it is still a draft).
  Future<void> deleteComplaint(int complaintId);
}
