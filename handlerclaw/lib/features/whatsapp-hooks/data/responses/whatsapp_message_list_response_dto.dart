import 'package:handlerclaw/features/whatsapp-hooks/data/dto/whatsapp_message_dto.dart';

class WhatsappMessageListResponseDto {
  final List<WhatsappMessageDto> messages;
  final WhatsappMessageListMetaDto meta;

  WhatsappMessageListResponseDto({
    required this.messages,
    required this.meta,
  });

  factory WhatsappMessageListResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final messagesJson = (data?['messages'] as List<dynamic>?) ?? [];
    
    return WhatsappMessageListResponseDto(
      messages: messagesJson
          .map((m) => WhatsappMessageDto.fromJson(m as Map<String, dynamic>))
          .toList(),
      meta: WhatsappMessageListMetaDto.fromJson(
        (data?['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class WhatsappMessageListMetaDto {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  WhatsappMessageListMetaDto({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory WhatsappMessageListMetaDto.fromJson(Map<String, dynamic> json) {
    return WhatsappMessageListMetaDto(
      page: json['page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
    );
  }
}
