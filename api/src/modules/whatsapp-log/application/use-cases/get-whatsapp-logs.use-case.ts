import type { GetWhatsappLogsQuery } from "../../infrastructure/models/whatsapp-log.schema.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import type { GetWhatsappLogsResponse } from "../dtos/whatsapp-log.dto.js";

export class GetWhatsappLogsUseCase {
  constructor(private whatsappLogRepository: WhatsappLogRepository) {}

  async execute(query: GetWhatsappLogsQuery): Promise<GetWhatsappLogsResponse> {
    const { take, cursor } = query;

    const { logs, nextCursor } = await this.whatsappLogRepository.findMany(take, cursor);

    return {
      whatsapp_logs: logs,
      next_cursor: nextCursor,
      filter: {
        date_type: query.date_type,
        start: query.date_type === "custom" ? query.start : undefined,
        end: query.date_type === "custom" ? query.end : undefined,
        filtered: {
          date_start: undefined,
          date_end: undefined,
        },
      },
    };
  }
}
