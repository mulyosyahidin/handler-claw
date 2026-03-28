import { prisma } from "../../../../config/index.js";
import { Prisma, type WhatsappLog } from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type {
  CreateWhatsappLogData,
  WhatsappLogFilter,
} from "../../application/dtos/whatsapp-log.dto.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";

export class PrismaWhatsappLogRepository implements WhatsappLogRepository {
  async create(data: CreateWhatsappLogData): Promise<WhatsappLog> {
    return prisma.whatsappLog.create({
      data: {
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
}
