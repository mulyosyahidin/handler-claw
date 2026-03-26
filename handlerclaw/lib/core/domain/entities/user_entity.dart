class UserEntity {
  final String id;
  final String name;
  final String email;
  final DateTime lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntity.empty() {
    return UserEntity(
      id: "",
      name: "",
      email: "",
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
