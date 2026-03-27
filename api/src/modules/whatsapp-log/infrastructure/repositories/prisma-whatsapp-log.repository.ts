import { prisma } from "../../../../config/index.js";
import type { Prisma } from "../../../../lib/generated/prisma/client.js";
import type { WhatsappLog } from "../../domain/entities/whatsapp-log.entity.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import { toWhatsappLogEntity } from "../mappers/whatsapp-log.mapper.js";
import { getPrayerDateFilter } from "../../../../utils/date-filter.js";

export class PrismaWhatsappLogRepository implements WhatsappLogRepository {
  async create(data: Prisma.WhatsappLogCreateInput): Promise<WhatsappLog> {
    const created = await prisma.whatsappLog.create({ data });

    return toWhatsappLogEntity(created);
  }

  async findMany(
    take: number,
    cursor?: number,
  ): Promise<{ logs: WhatsappLog[]; nextCursor: number | null }> {
    const logs = await prisma.whatsappLog.findMany({
      orderBy: { id: "desc" },
      take: take + 1,
      ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    });

    let nextCursor: number | null = null;
    if (logs.length > take) {
      const lastItem = logs.pop();
      nextCursor = lastItem!.id;
    }

    return {
      logs: logs.map(toWhatsappLogEntity),
      nextCursor,
    };
  }

  async getSummaryData(query: any): Promise<{
    total: number;
    byDeviceRaw: any[];
    byMessageTypeRaw: any[];
    byIsGroupRaw: any[];
    logsRaw: any[];
    filterInfo: any;
  }> {
    const { date_type, start, end } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const where: any = {
      receivedAt: dateFilter.date,
    };

    const [total, byDeviceRaw, byMessageTypeRaw, byIsGroupRaw, logsRaw] = await Promise.all([
      prisma.whatsappLog.count({ where }),
      prisma.whatsappLog.groupBy({
        by: ["device"],
        where,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["messageType"],
        where,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["isGroup"],
        where,
        _count: { id: true },
      }),
      prisma.whatsappLog.findMany({
        where,
        orderBy: { receivedAt: "desc" },
      }),
    ]);

    return {
      total,
      byDeviceRaw,
      byMessageTypeRaw,
      byIsGroupRaw,
      logsRaw,
      filterInfo: { date_start, date_end },
    };
  }
}
