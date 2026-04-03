import type { WhatsappMessageRepository } from "../../domain/repositories/whatsapp-message.repository.js";
import { toWhatsappMessageEntity } from "../../infrastructure/mappers/whatsapp-message.mapper.js";
import type {
  GetWhatsappMessagesQuery,
  GetWhatsappMessagesResponse,
  WhatsappMessageFilter,
} from "../dtos/whatsapp-message.dto.js";

export class GetWhatsappMessagesUseCase {
  constructor(private whatsappMessageRepository: WhatsappMessageRepository) {}

  async execute(
    userId: string | null,
    query: GetWhatsappMessagesQuery,
  ): Promise<GetWhatsappMessagesResponse> {
    const { page, per_page, search, chat_id, message_type } = query;

    const skip = (page - 1) * per_page;
    const take = per_page;

    const filter: WhatsappMessageFilter = {};

    if (search?.trim()) {
      filter.search = search.trim();
    }

    if (chat_id) {
      filter.chatId = chat_id;
    }

    if (message_type) {
      filter.messageType = message_type;
    }

    if (userId) {
      filter.userId = userId;
    }

    if (query.is_from_me !== undefined) {
      filter.isFromMe =
        query.is_from_me === "true" || query.is_from_me === true;
    }

    const { messages, total } = await this.whatsappMessageRepository.findAll(filter, {
      skip,
      take,
    });

    return {
      messages: messages.map(toWhatsappMessageEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    };
  }
}
