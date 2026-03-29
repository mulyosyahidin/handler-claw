import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import { toWhatsappLogEntity } from "../../infrastructure/mappers/whatsapp-log.mapper.js";
import type {
  GetWhatsappLogsQuery,
  GetWhatsappLogsResponse,
  WhatsappLogFilter,
} from "../dtos/whatsapp-log.dto.js";

export class GetWhatsappLogsUseCase {
  constructor(private whatsappLogRepository: WhatsappLogRepository) {}

  async execute(query: GetWhatsappLogsQuery): Promise<GetWhatsappLogsResponse> {
    const { page, per_page, search, is_group } = query;

    const skip = (page - 1) * per_page;
    const take = per_page;

    const filter: WhatsappLogFilter = {};

    const normalizedSearch = search?.trim();
    if (normalizedSearch) {
      filter.search = normalizedSearch;
    }

    if (is_group !== undefined) {
      filter.isGroup = is_group;
    }

    const { logs, total } = await this.whatsappLogRepository.findAll(filter, { skip, take });

    return {
      whatsapp_logs: logs.map(toWhatsappLogEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    };
  }
}
