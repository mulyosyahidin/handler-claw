import { prisma } from "../../../../../config/index.js";
import { Prisma, type WhatsappLog } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateWhatsappLogData,
  WhatsappLogFilter,
} from "../../application/dtos/whatsapp-log.dto.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";

export class PrismaWhatsappLogRepository implements WhatsappLogRepository {
  async create(data: CreateWhatsappLogData): Promise<WhatsappLog> {
    return prisma.whatsappLog.create({
      data: {
        userId: data.userId,
        device: data.device,
        mode: data.mode,
        sender: data.sender,
        senderLid: data.senderLid,
        senderName: data.senderName,
        isGroup: data.isGroup,
        groupId: data.groupId,
        memberPhone: data.memberPhone,
        memberLid: data.memberLid,
        messageText: data.messageText,
        messageType: data.messageType,
        isForwarded: data.isForwarded,
        isQuick: data.isQuick,
        inboxId: data.inboxId,
        extension: data.extension,
        filename: data.filename,
        url: data.url,
        location: data.location,
        pollName: data.pollName,
        pollChoices: data.pollChoices,
        waTimestamp: data.waTimestamp,
      },
    });
  }

  async findAll(
    filter: WhatsappLogFilter,
    pagination: PaginationType,
  ): Promise<{ logs: WhatsappLog[]; total: number }> {
    const { search } = filter;
    const { skip, take } = pagination;

    const where: Prisma.WhatsappLogWhereInput = {
      ...(search && {
        OR: [
          { sender: { contains: search, mode: "insensitive" } },
          { senderName: { contains: search, mode: "insensitive" } },
          { messageText: { contains: search, mode: "insensitive" } },
        ],
      }),
      ...(filter.isGroup !== undefined && { isGroup: filter.isGroup }),
      ...(filter.userId !== undefined && { userId: filter.userId }),
    };

    const [total, logs] = await Promise.all([
      prisma.whatsappLog.count({ where }),
      prisma.whatsappLog.findMany({
        where,
        orderBy: { receivedAt: "desc" },
        skip,
        take,
      }),
    ]);

    return { logs, total };
  }

  async findSummary(
    userId: string | null,
    filter: any,
  ): Promise<
    {
      date: string;
      is_group: boolean;
      count: number;
    }[]
  > {
    const conditions: string[] = [];
    const values: any[] = [];
    let idx = 1;

    if (userId) {
      conditions.push(`"user_id" = $${idx++}`);
      values.push(userId);
    } else {
      conditions.push(`"user_id" IS NULL`);
    }

    if (filter?.date?.gte) {
      conditions.push(`"received_at" >= $${idx++}`);
      values.push(filter.date.gte);
    }

    if (filter?.date?.lt) {
      conditions.push(`"received_at" < $${idx++}`);
      values.push(filter.date.lt);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await prisma.$queryRawUnsafe<
      {
        date: string;
        is_group: boolean;
        count: number;
      }[]
    >(
      `
      SELECT
        DATE("received_at") as date,
        is_group,
        COUNT(*) as count
      FROM whatsapp_logs
      ${whereClause}
      GROUP BY DATE("received_at"), is_group
      ORDER BY DATE("received_at") ASC
    `,
      ...values,
    );

    return result;
  }
}
