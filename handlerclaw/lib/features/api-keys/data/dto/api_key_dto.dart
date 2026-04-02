class ApiKeyDto {
  final String id;
  final String userId;
  final String keyPreview;
  final String name;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? plainKey;

  ApiKeyDto({
    required this.id,
    required this.userId,
    required this.keyPreview,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.plainKey,
  });

  factory ApiKeyDto.fromJson(Map<String, dynamic> json) {
    return ApiKeyDto(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      keyPreview: json['key_preview'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      plainKey: json['plain_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'key_preview': keyPreview,
      'name': name,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'plain_key': plainKey,
    };
  }
}
