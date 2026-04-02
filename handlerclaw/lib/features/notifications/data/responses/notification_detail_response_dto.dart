import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/features/notifications/data/dto/notification_dto.dart';

class NotificationDetailData {
  final NotificationDto notification;

  NotificationDetailData({required this.notification});

  factory NotificationDetailData.fromJson(Map<String, dynamic> json) {
    return NotificationDetailData(
      notification: NotificationDto.fromJson(json['notification'] ?? {}),
    );
  }
}

class NotificationDetailResponseDto
    extends ApiResponseDto<NotificationDetailData> {
  NotificationDetailResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory NotificationDetailResponseDto.fromJson(Map<String, dynamic> json) {
    return NotificationDetailResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? NotificationDetailData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
