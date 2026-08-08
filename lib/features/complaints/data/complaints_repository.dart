import 'complaints_mock.dart';
import '../presentation/models/complaint_models.dart' as models;

class ComplaintsRepository {
  const ComplaintsRepository();

  List<models.Complaint> getComplaints() => complaintMocks;
}
