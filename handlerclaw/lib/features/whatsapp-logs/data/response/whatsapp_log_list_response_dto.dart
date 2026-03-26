import 'package:handlerclaw/core/models/dto/whatsapp_log_dto.dart';

class WhatsappLogListResponseDto {
  final List<WhatsappLogDto> whatsappLogs;
  final int? nextCursor;

  WhatsappLogListResponseDto({
    required this.whatsappLogs,
    this.nextCursor,
  });

  factory WhatsappLogListResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final logs = data['whatsapp_logs'] as List? ?? [];
    
    return WhatsappLogListResponseDto(
      whatsappLogs: logs.map((log) => WhatsappLogDto.fromJson(log)).toList(),
      nextCursor: data['next_cursor'],
    );
  }
}
