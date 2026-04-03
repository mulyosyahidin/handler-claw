import 'package:handlerclaw/features/whatsapp-hooks/domain/entities/whatsapp_message_entity.dart';

abstract class WhatsappHookRepository {
  Future<({List<WhatsappMessageEntity> messages, int total})> getMessages({
    int page = 1,
    int limit = 10,
    String? search,
    String? chatId,
    WhatsappMessageType? messageType,
    bool? isFromMe,
  });
}
