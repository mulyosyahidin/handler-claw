import type { Prisma } from "../../../../lib/generated/prisma/client.js";
import type { WhatsappLog } from "../entities/whatsapp-log.entity.js";

export interface WhatsappLogRepository {
  create(data: Prisma.WhatsappLogCreateInput): Promise<WhatsappLog>;
  findMany(
    take: number,
    cursor?: number,
  ): Promise<{ logs: WhatsappLog[]; nextCursor: number | null }>;
  getSummaryData(query: any): Promise<{
    total: number;
    byDeviceRaw: any[];
    byMessageTypeRaw: any[];
    byIsGroupRaw: any[];
    logsRaw: any[];
    filterInfo: any;
  }>;
}
