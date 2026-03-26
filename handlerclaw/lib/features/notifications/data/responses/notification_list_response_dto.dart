import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/notifications/data/dto/notification_dto.dart';

class NotificationListData {
  final List<NotificationDto> notifications;
  final PaginationMetaDto meta;

  NotificationListData({required this.notifications, required this.meta});

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMetaDto.fromJson(json['meta'] ?? {}),
    );
  }
}

class NotificationListResponseDto extends ApiResponseDto<NotificationListData> {
  NotificationListResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory NotificationListResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationListResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? NotificationListData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
