import 'package:handlerclaw/features/whatsapp-logs/data/dto/whatsapp_log_dto.dart';
import 'package:handlerclaw/features/whatsapp-logs/domain/entities/whatsapp_log_entity.dart';

class WhatsappLogMapper {
  static WhatsappLogEntity fromDto(WhatsappLogDto dto) {
    return WhatsappLogEntity(
      id: dto.id,
      receivedAt: dto.receivedAt,
      device: dto.device,
      mode: dto.mode,
      sender: dto.sender,
      senderLid: dto.senderLid,
      senderName: dto.senderName,
      isGroup: dto.isGroup,
      groupId: dto.groupId,
      memberPhone: dto.memberPhone,
      memberLid: dto.memberLid,
      messageText: dto.messageText,
      messageType: dto.messageType,
      isForwarded: dto.isForwarded,
      isQuick: dto.isQuick,
      inboxId: dto.inboxId,
      extension: dto.extension,
      filename: dto.filename,
      url: dto.url,
      location: dto.location,
      pollName: dto.pollName,
      pollChoices: dto.pollChoices,
      waTimestamp: dto.waTimestamp,
    );
  }

  static List<WhatsappLogEntity> fromDtos(List<WhatsappLogDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }
}
