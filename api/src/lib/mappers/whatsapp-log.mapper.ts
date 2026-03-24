import type { WhatsappLog } from "../generated/prisma/client.js";
import type { IWhatsappLog } from "../types/domain/index.js";

export function toWhatsappLogEntity(p: WhatsappLog): IWhatsappLog {
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
    poll_choices: p.pollChoices,
    wa_timestamp: p.waTimestamp.toString(),
  };
}
