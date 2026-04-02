import 'package:handlerclaw/core/models/api_response_dto.dart';
import 'package:handlerclaw/core/models/pagination_meta_dto.dart';
import 'package:handlerclaw/features/whatsapp-logs/data/dto/whatsapp_log_dto.dart';

class WhatsappLogListData {
  final List<WhatsappLogDto> whatsappLogs;
  final PaginationMetaDto meta;

  WhatsappLogListData({
    required this.whatsappLogs,
    required this.meta,
  });

  factory WhatsappLogListData.fromJson(Map<String, dynamic> json) {
    return WhatsappLogListData(
      whatsappLogs:
          (json['whatsapp_logs'] as List<dynamic>?)
              ?.map((e) => WhatsappLogDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meta: PaginationMetaDto.fromJson(json['meta'] as Map<String, dynamic>),
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
