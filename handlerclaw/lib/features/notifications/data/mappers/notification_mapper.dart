import 'package:handlerclaw/features/notifications/domain/entities/notification_entity.dart';
import 'package:handlerclaw/features/notifications/data/dto/notification_dto.dart';

class NotificationMapper {
  static NotificationEntity fromDto(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      notificationWebhookId: dto.notificationWebhookId,
      userId: dto.userId,
      userDeviceId: dto.userDeviceId,
      title: dto.title,
      body: dto.body,
      data: dto.data,
      triggeredAt: dto.triggeredAt,
      status: dto.status,
      fcmMessageId: dto.fcmMessageId,
      sentAt: dto.sentAt,
      failedAt: dto.failedAt,
      retryCount: dto.retryCount,
      errorMessage: dto.errorMessage,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<NotificationEntity> fromDtos(List<NotificationDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }
}
