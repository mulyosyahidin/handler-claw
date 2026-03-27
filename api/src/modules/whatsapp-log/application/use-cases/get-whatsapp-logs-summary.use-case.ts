import { format } from "date-fns";
import { toZonedTime } from "date-fns-tz";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import { toWhatsappLogEntity } from "../../infrastructure/mappers/whatsapp-log.mapper.js";
import type { GetWhatsappLogsSummaryQuery } from "../../infrastructure/models/whatsapp-log.schema.js";
import type {
  GetWhatsappLogsSummaryResponse,
  WhatsappLogSenderGroup,
} from "../dtos/whatsapp-log.dto.js";

export class GetWhatsappLogsSummaryUseCase {
  constructor(private whatsappLogRepository: WhatsappLogRepository) {}

  async execute(query: GetWhatsappLogsSummaryQuery): Promise<GetWhatsappLogsSummaryResponse> {
    const { total, byDeviceRaw, byMessageTypeRaw, byIsGroupRaw, logsRaw, filterInfo } =
      await this.whatsappLogRepository.getSummaryData(query);

    const by_device = byDeviceRaw.reduce(
      (acc: any, curr: any) => ({ ...acc, [curr.device]: curr._count.id }),
      {} as Record<string, number>,
    );

    const by_message_type = byMessageTypeRaw.reduce(
      (acc: any, curr: any) => ({ ...acc, [curr.messageType]: curr._count.id }),
      {} as Record<string, number>,
    );

    const groupCount = byIsGroupRaw.find((x: any) => x.isGroup)?._count.id || 0;
    const personalCount = byIsGroupRaw.find((x: any) => !x.isGroup)?._count.id || 0;

    const messagesMap: Record<
      string,
      Record<string, { sender_name: string | null; messages: any[] }>
    > = {};

    for (const log of logsRaw) {
      const jakartaTime = toZonedTime(log.receivedAt, "Asia/Jakarta");
      const dateKey = format(jakartaTime, "yyyy-MM-dd");
      const senderKey = log.sender;

      if (!messagesMap[dateKey]) messagesMap[dateKey] = {};
      if (!messagesMap[dateKey][senderKey]) {
        messagesMap[dateKey][senderKey] = {
          sender_name: log.senderName,
          messages: [],
        };
      }

      messagesMap[dateKey][senderKey].messages.push(toWhatsappLogEntity(log));
    }

    const messages: Record<string, WhatsappLogSenderGroup[]> = {};

    for (const [dateKey, senders] of Object.entries(messagesMap)) {
      messages[dateKey] = Object.entries(senders).map(([senderKey, data]) => ({
        sender_name: data.sender_name,
        sender: senderKey,
        messages: data.messages,
      }));
    }

    return {
      filter: {
        date_type: query.date_type,
        start: query.date_type === "custom" ? query.start : undefined,
        end: query.date_type === "custom" ? query.end : undefined,
        filtered: filterInfo,
      },
      total,
      by_device,
      by_message_type,
      by_chat_type: {
        group: groupCount,
        personal: personalCount,
      },
      messages,
    };
  }
}
