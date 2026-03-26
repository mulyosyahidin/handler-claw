import 'package:handlerclaw/features/notifications/domain/entities/notification_entity.dart';
import 'package:handlerclaw/features/notifications/domain/entities/notification_payload_entity.dart';
import 'package:handlerclaw/features/notifications/data/dto/notification_dto.dart';

class NotificationMapper {
  static NotificationEntity fromDto(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      userId: dto.userId,
      eventId: dto.eventId,
      status: dto.status,
      headers: dto.headersJson,
      payload: NotificationPayloadEntity(
        type: dto.payloadJson.type,
        title: dto.payloadJson.title,
        linkTo: dto.payloadJson.linkTo,
        message: dto.payloadJson.message,
        eventId: dto.payloadJson.eventId,
        meta: dto.payloadJson.meta,
      ),
      errorMessage: dto.errorMessage,
      processedAt: dto.processedAt,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  static List<NotificationEntity> fromDtos(List<NotificationDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }
}
