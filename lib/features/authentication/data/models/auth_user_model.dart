class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.roles,
    required this.accountType,
    this.citizenProfile,
    this.employeeProfile,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: _requiredInt(json, 'id'),
      name: _requiredString(json, 'name'),
      email: _requiredString(json, 'email'),
      phoneNumber: _nullableString(json['phone_number']),
      roles: _stringList(json['roles']),
      accountType: _requiredString(json, 'account_type'),
      citizenProfile: _nullableMap(json['citizen_profile']),
      employeeProfile: _nullableMap(json['employee_profile']),
    );
  }

  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<String> roles;
  final String accountType;
  final Map<String, dynamic>? citizenProfile;
  final Map<String, dynamic>? employeeProfile;

  bool get isCitizen => accountType == 'citizen';
  bool get isEmployee => accountType == 'employee';

  String get displayName {
    final fullName = _nullableString(citizenProfile?['full_name']);
    return fullName ?? name;
  }

  bool? get isCitizenVerified {
    final value = citizenProfile?['is_verified'];
    if (value is bool) return value;
    if (value is int) return value == 1;
    return null;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'roles': roles,
      'account_type': accountType,
      'citizen_profile': citizenProfile,
      'employee_profile': employeeProfile,
    };
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw FormatException('Missing or invalid "$key" in user payload.');
  }

  static String _requiredString(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = _nullableString(json[key]);
    if (value != null) return value;
    throw FormatException('Missing or invalid "$key" in user payload.');
  }

  static String? _nullableString(Object? value) {
    if (value == null) return null;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static List<String> _stringList(Object? value) {
    if (value is! Iterable) return const [];
    return List<String>.unmodifiable(
      value.map(_nullableString).whereType<String>(),
    );
  }

  static Map<String, dynamic>? _nullableMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(value);
    }
    if (value is Map) {
      return Map<String, dynamic>.unmodifiable(
        value.map(
          (key, dynamic item) => MapEntry(key.toString(), item),
        ),
      );
    }
    throw const FormatException('Invalid profile payload.');
  }
}
