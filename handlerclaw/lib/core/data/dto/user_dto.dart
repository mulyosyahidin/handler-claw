class UserDto {
  final String id;
  final String name;
  final String email;
  final String driver;
  final String? avatarUrl;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.driver,
    this.avatarUrl,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      driver: json['driver'] ?? 'EMAIL',
      avatarUrl: json['avatar_url'],
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  factory UserDto.empty() {
    return UserDto(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'driver': driver,
      'avatar_url': avatarUrl,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
