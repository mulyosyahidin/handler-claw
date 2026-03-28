import type { WhatsappLog } from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type {
  CreateWhatsappLogData,
  WhatsappLogFilter,
} from "../../application/dtos/whatsapp-log.dto.js";

export interface WhatsappLogRepository {
  create(data: CreateWhatsappLogData): Promise<WhatsappLog>;
  findAll(
    filter: WhatsappLogFilter,
    pagination: PaginationType,
  ): Promise<{ logs: WhatsappLog[]; total: number }>;
}
