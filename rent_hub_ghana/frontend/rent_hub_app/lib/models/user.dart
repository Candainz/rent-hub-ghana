class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.organizationName = '',
  });
  final int id;
  final String username,
      email,
      role,
      firstName,
      lastName,
      phone,
      organizationName;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as int? ?? 0,
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? 'renter',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    organizationName: json['organization_name'] as String? ?? '',
  );

  String get displayName => '$firstName $lastName'.trim().isEmpty
      ? username
      : '$firstName $lastName'.trim();
}
