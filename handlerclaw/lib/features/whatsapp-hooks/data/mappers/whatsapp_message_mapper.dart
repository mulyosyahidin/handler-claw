import 'package:handlerclaw/features/whatsapp-hooks/data/dto/whatsapp_message_dto.dart';
import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';

class WhatsappMessageMapper {
  static WhatsappMessageEntity toEntity(WhatsappMessageDto dto) {
    return WhatsappMessageEntity(
      id: dto.id,
      webhookLogId: dto.webhookLogId,
      chatId: dto.chatId,
      chatLid: dto.chatLid,
      from: dto.from,
      fromLid: dto.fromLid,
      fromName: dto.fromName,
      isFromMe: dto.isFromMe,
      waTimestamp: dto.waTimestamp,
      messageType: WhatsappMessageType.fromString(dto.messageType),
      body: dto.body,
      repliedToId: dto.repliedToId,
      quotedBody: dto.quotedBody,
      isForwarded: dto.isForwarded,
      mediaPath: dto.mediaPath,
      fullPathMedia: dto.fullMediaPath,
      mediaCaption: dto.mediaCaption,
      originalUrl: dto.originalUrl,
      latitude: dto.latitude,
      longitude: dto.longitude,
      locationThumbnail: dto.locationThumbnail,
      locationSequence: dto.locationSequence != null
          ? BigInt.tryParse(dto.locationSequence!)
          : null,
      contactName: dto.contactName,
      contactVcard: dto.contactVcard,
      contacts: dto.contacts,
      reaction: dto.reaction,
      reactedMessageId: dto.reactedMessageId,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
