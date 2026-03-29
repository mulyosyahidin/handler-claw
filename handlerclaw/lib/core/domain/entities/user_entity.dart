class UserEntity {
  final String id;
  final String name;
  final String email;
  final String driver;
  final String? avatarUrl;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.driver,
    this.avatarUrl,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntity.empty() {
    return UserEntity(
      id: "",
      name: "",
      email: "",
      driver: "EMAIL",
      avatarUrl: null,
      lastLoginAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
