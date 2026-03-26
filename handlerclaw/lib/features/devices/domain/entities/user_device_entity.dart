class UserDeviceEntity {
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

  UserDeviceEntity({
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

  bool get isOnline => status == 'ACTIVE';
}
