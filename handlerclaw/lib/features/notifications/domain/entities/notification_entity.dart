import 'package:handlerclaw/features/notifications/domain/entities/notification_payload_entity.dart';

class NotificationEntity {
  final String id;
  final String userId;
  final String eventId;
  final String status;
  final Map<String, dynamic> headers;
  final NotificationPayloadEntity payload;
  final String? errorMessage;
  final DateTime? processedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
    required this.headers,
    required this.payload,
    this.errorMessage,
    this.processedAt,
    required this.createdAt,
    required this.updatedAt,
  });
}
