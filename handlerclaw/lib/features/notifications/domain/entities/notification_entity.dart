class NotificationEntity {
  final String id;
  final String notificationWebhookId;
  final String userId;
  final String userDeviceId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? triggeredAt;
  final String status;
  final String? fcmMessageId;
  final DateTime? sentAt;
  final DateTime? failedAt;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationEntity({
    required this.id,
    required this.notificationWebhookId,
    required this.userId,
    required this.userDeviceId,
    required this.title,
    required this.body,
    required this.data,
    this.triggeredAt,
    required this.status,
    this.fcmMessageId,
    this.sentAt,
    this.failedAt,
    required this.retryCount,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
}
