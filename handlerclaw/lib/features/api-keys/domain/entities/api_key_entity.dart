enum ApiKeyStatus {
  active,
  revoked,
  expired,
}

class ApiKeyEntity {
  final String id;
  final String name;
  final String keyPreview;
  final ApiKeyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? plainKey;

  ApiKeyEntity({
    required this.id,
    required this.name,
    required this.keyPreview,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.plainKey,
  });

  bool get isActive => status == ApiKeyStatus.active;
  bool get isRevoked => status == ApiKeyStatus.revoked;
}
