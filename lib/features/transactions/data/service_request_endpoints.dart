class ServiceRequestEndpoints {
  ServiceRequestEndpoints._();

  static const String _citizen = 'citizen';

  static const String services = '$_citizen/services';
  static const String requests = '$_citizen/service-requests';
  static const String drafts = '$requests/drafts';

  static String service(int serviceTypeId) => '$services/$serviceTypeId';

  static String request(int requestId) => '$requests/$requestId';

  static String attachments(int requestId) => '${request(requestId)}/attachments';

  static String attachment(int requestId, int attachmentId) =>
      '${attachments(requestId)}/$attachmentId';

  static String submit(int requestId) => '${request(requestId)}/submit';

  static String document(int requestId) => '${request(requestId)}/document';
}
