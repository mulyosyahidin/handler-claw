import type { WhatsappLog } from "../../../../lib/generated/prisma/client.js";
import type { IWhatsappLog } from "../../domain/entities/whatsapp-log.entity.js";

export function toWhatsappLogEntity(data: WhatsappLog): IWhatsappLog {
  return {
    id: data.id,
    user_id: data.userId,
    received_at: data.receivedAt,
    device: data.device,
    mode: data.mode,
    sender: data.sender,
    sender_lid: data.senderLid,
    sender_name: data.senderName,
    is_group: data.isGroup,
    group_id: data.groupId,
    member_phone: data.memberPhone,
    member_lid: data.memberLid,
    message_text: data.messageText,
    message_type: data.messageType,
    is_forwarded: data.isForwarded,
    is_quick: data.isQuick,
    inbox_id: data.inboxId,
    extension: data.extension,
    filename: data.filename,
    url: data.url,
    location: data.location,
    poll_name: data.pollName,
    poll_choices: data.pollChoices as any,
    wa_timestamp: data.waTimestamp.toString(),
  };
}
