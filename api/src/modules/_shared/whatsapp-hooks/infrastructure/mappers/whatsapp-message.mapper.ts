import type { WhatsappMessage } from "../../../../../lib/generated/prisma/client.js";
import type { IWhatsappMessage } from "../../domain/entities/whatsapp-message.entity.js";

export function toWhatsappMessageEntity(data: WhatsappMessage): IWhatsappMessage {
  return {
    id: data.id,
    webhook_log_id: data.webhookLogId,

    chat_id: data.chatId,
    chat_lid: data.chatLid,
    from: data.from,
    from_lid: data.fromLid,
    from_name: data.fromName,
    is_from_me: data.isFromMe,
    wa_timestamp: data.waTimestamp,

    message_type: data.messageType,
    body: data.body,

    replied_to_id: data.repliedToId,
    quoted_body: data.quotedBody,
    is_forwarded: data.isForwarded,

    media_path: data.mediaPath,
    full_media_path: data.mediaPath
      ? `${(process.env.APP_BASE_URL || "").endsWith("/") ? process.env.APP_BASE_URL : (process.env.APP_BASE_URL || "") + "/"}${data.mediaPath.startsWith("/") ? data.mediaPath.substring(1) : data.mediaPath}`
      : null,
    media_caption: data.mediaCaption,
    original_url: data.originalUrl,

    latitude: data.latitude,
    longitude: data.longitude,
    location_thumbnail: data.locationThumbnail,
    location_sequence: data.locationSequence,

    contact_name: data.contactName,
    contact_vcard: data.contactVcard,
    contacts: data.contacts,

    reaction: data.reaction,
    reacted_message_id: data.reactedMessageId,

    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
