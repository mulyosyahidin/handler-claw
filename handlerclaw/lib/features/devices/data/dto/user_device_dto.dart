class UserDeviceDto {
  final String id;
  final String userId;
  final String deviceId;
  final String? deviceBrand;
  final String? deviceModel;
  final String? osVersion;
  final String fcmToken;
  final String platform;
  final String status;
  final DateTime? lastSeenAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDeviceDto({
    required this.id,
    required this.userId,
    required this.deviceId,
    this.deviceBrand,
    this.deviceModel,
    this.osVersion,
    required this.fcmToken,
    required this.platform,
    required this.status,
    this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserDeviceDto.fromJson(Map<String, dynamic> json) {
    return UserDeviceDto(
      id: json['id'],
      userId: json['user_id'],
      deviceId: json['device_id'],
      deviceBrand: json['device_brand'],
      deviceModel: json['device_model'],
      osVersion: json['os_version'],
      fcmToken: json['fcm_token'],
      platform: json['platform'],
      status: json['status'],
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'device_id': deviceId,
      'device_brand': deviceBrand,
      'device_model': deviceModel,
      'os_version': osVersion,
      'fcm_token': fcmToken,
      'platform': platform,
      'status': status,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
