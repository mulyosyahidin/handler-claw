class NotificationDto {
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

  NotificationDto({
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

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] ?? '',
      notificationWebhookId: json['notification_webhook_id'] ?? '',
      userId: json['user_id'] ?? '',
      userDeviceId: json['user_device_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : {},
      triggeredAt: json['triggered_at'] != null 
          ? DateTime.parse(json['triggered_at']) 
          : null,
      status: json['status'] ?? '',
      fcmMessageId: json['fcm_message_id'],
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at']) 
          : null,
      failedAt: json['failed_at'] != null 
          ? DateTime.parse(json['failed_at']) 
          : null,
      retryCount: json['retry_count'] ?? 0,
      errorMessage: json['error_message'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_webhook_id': notificationWebhookId,
      'user_id': userId,
      'user_device_id': userDeviceId,
      'title': title,
      'body': body,
      'data': data,
      'triggered_at': triggeredAt?.toIso8601String(),
      'status': status,
      'fcm_message_id': fcmMessageId,
      'sent_at': sentAt?.toIso8601String(),
      'failed_at': failedAt?.toIso8601String(),
      'retry_count': retryCount,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
