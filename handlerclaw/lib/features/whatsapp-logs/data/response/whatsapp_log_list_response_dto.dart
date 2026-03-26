import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/dto/whatsapp_log_dto.dart';

class WhatsappLogListData {
  final List<WhatsappLogDto> whatsappLogs;
  final int? nextCursor;

  WhatsappLogListData({
    required this.whatsappLogs,
    this.nextCursor,
  });

  factory WhatsappLogListData.fromJson(Map<String, dynamic> json) {
    return WhatsappLogListData(
      whatsappLogs:
          (json['whatsapp_logs'] as List<dynamic>?)
              ?.map((e) => WhatsappLogDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextCursor: json['next_cursor'],
    );
  }
}

class WhatsappLogListResponseDto extends ApiResponseDto<WhatsappLogListData> {
  WhatsappLogListResponseDto({
    required super.success,
    required super.message,
    required super.data,
    super.errors,
  });

  factory WhatsappLogListResponseDto.fromJson(Map<String, dynamic> json) {
    return WhatsappLogListResponseDto(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] != null
          ? WhatsappLogListData.fromJson(json["data"])
          : null,
      errors: json["errors"],
    );
  }
}
