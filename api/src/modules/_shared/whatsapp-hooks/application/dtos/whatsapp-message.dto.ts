import type { WhatsappMessageType, Prisma } from "../../../../../lib/generated/prisma/client.js";
import type { IWhatsappMessage } from "../../domain/entities/whatsapp-message.entity.js";

/**
 * Filter and Pagination Contracts
 */
export type GetWhatsappMessagesQuery = {
  page: number;
  per_page: number;
  search?: string;
  chat_id?: string;
  message_type?: WhatsappMessageType;
  is_from_me?: string | boolean;
};

export type WhatsappMessageFilter = {
  search?: string;
  chatId?: string;
  messageType?: WhatsappMessageType;
  userId?: string;
  isFromMe?: boolean;
};

export type GetWhatsappMessagesResponse = {
  messages: IWhatsappMessage[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
};

export type CreateWhatsappMessageData = {
  id: string;
  webhookLogId: string;

  chatId: string;
  chatLid?: string | null;
  from: string;
  fromLid?: string | null;
  fromName?: string | null;
  isFromMe: boolean;
  waTimestamp: Date | string;

  messageType: WhatsappMessageType;
  body?: string | null;

  repliedToId?: string | null;
  quotedBody?: string | null;
  isForwarded: boolean;

  mediaPath?: string | null;
  mediaCaption?: string | null;
  originalUrl?: string | null;

  latitude?: number | null;
  longitude?: number | null;
  locationThumbnail?: string | null;
  locationSequence?: bigint | number | string | null;

  contactName?: string | null;
  contactVcard?: string | null;
  contacts?: Prisma.InputJsonValue | null;

  reaction?: string | null;
  reactedMessageId?: string | null;
};

export type WhatsappMessageResponse = {
  whatsapp_message: IWhatsappMessage;
};
