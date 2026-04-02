import 'package:handlerclaw/features/notifications/data/responses/notification_list_response_dto.dart';
import 'package:handlerclaw/features/notifications/data/responses/notification_detail_response_dto.dart';

abstract class NotificationRepository {
  Future<NotificationListResponseDto> getNotifications({
    int page = 1,
    int limit = 10,
  });

  Future<NotificationDetailResponseDto> getNotificationDetail(String id);
}
