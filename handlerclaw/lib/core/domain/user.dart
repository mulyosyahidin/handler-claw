class User {
  final String id;
  final String name;
  final String email;
  final String lastLoginAt;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
