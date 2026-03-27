import type { WhatsappLog } from "../../../../lib/generated/prisma/client.js";
import type { WhatsappLog as Entity } from "../../domain/entities/whatsapp-log.entity.js";

export function toWhatsappLogEntity(p: WhatsappLog): Entity {
  return {
    id: p.id,
    received_at: p.receivedAt,
    device: p.device,
    mode: p.mode,
    sender: p.sender,
    sender_lid: p.senderLid,
    sender_name: p.senderName,
    is_group: p.isGroup,
    group_id: p.groupId,
    member_phone: p.memberPhone,
    member_lid: p.memberLid,
    message_text: p.messageText,
    message_type: p.messageType,
    is_forwarded: p.isForwarded,
    is_quick: p.isQuick,
    inbox_id: p.inboxId,
    extension: p.extension,
    filename: p.filename,
    url: p.url,
    location: p.location,
    poll_name: p.pollName,
    poll_choices: p.pollChoices as any,
    wa_timestamp: p.waTimestamp.toString(),
  };
}
