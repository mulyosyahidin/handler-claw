import prisma from "../config/prisma.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type {
  CreateWhatsappLogResponseData,
  GetWhatsappLogsResponseData,
  GetWhatsappLogsSummaryResponseData,
} from "../lib/types/data/whatsapp-log.types.js";
import type {
  CreateWhatsappLogInput,
  GetWhatsappLogsQuery,
  GetWhatsappLogsSummaryQuery,
} from "../lib/schemas/whatsapp-log.schema.js";
import { toWhatsappLogEntity } from "../lib/mappers/whatsapp-log.mapper.js";
import { Prisma } from "../lib/generated/prisma/client.js";
import { getWhatsappDateFilter } from "../lib/utils/whatsapp-date-filter.js";
import { format } from "date-fns";
import { toZonedTime } from "date-fns-tz";

export class WhatsappLogService {
  // ─── CREATE ──────────────────────────────────────────────────────────────

  async createLog(
    data: CreateWhatsappLogInput,
  ): Promise<SuccessResponse<CreateWhatsappLogResponseData>> {
    const log = await prisma.whatsappLog.create({
      data: {
        device: data.device,
        mode: data.mode,
        isQuick: data.quick,
        inboxId: data.inboxid,

        sender: data.sender,
        // Gunakan ?? null untuk semua field optional
        senderLid: data.senderlid ?? null,
        senderName: data.name ?? null,

        isGroup: data.isgroup,
        groupId: data.member ?? null,
        memberPhone: data.member ?? null,
        memberLid: data.memberlid ?? null,

        messageText: (data.message || data.pesan) ?? null,
        messageType: data.type,
        isForwarded: data.isforwarded,

        extension: data.extension ?? null,
        filename: data.filename ?? null,
        url: data.url ?? null,
        location: data.location ?? null,

        pollName: data.pollname ?? null,
        pollChoices: data.choices?.length ? data.choices : Prisma.JsonNull,

        waTimestamp: data.timestamp,
      },
    });

    return createSuccessResponse("Berhasil menyimpan whatsapp log", {
      whatsapp_log: toWhatsappLogEntity(log),
    });
  }

  // ─── GET (cursor-based pagination) ───────────────────────────────────────

  async getLogs(
    query: GetWhatsappLogsQuery,
  ): Promise<SuccessResponse<GetWhatsappLogsResponseData>> {
    const { cursor, take, date_type, start, end, search } = query;
    const {
      filter: dateFilter,
      date_start,
      date_end,
    } = getWhatsappDateFilter(date_type, start, end);

    const searchFilter: Prisma.WhatsappLogWhereInput = search
      ? {
          OR: [
            { senderName: { contains: search, mode: "insensitive" } },
            { sender: { contains: search, mode: "insensitive" } },
            { senderLid: { contains: search, mode: "insensitive" } },
            { messageText: { contains: search, mode: "insensitive" } },
          ],
        }
      : {};

    const where: Prisma.WhatsappLogWhereInput = {
      AND: [dateFilter, searchFilter],
    };

    const logs = await prisma.whatsappLog.findMany({
      where,
      take: take + 1,
      ...(cursor !== undefined && {
        cursor: { id: cursor },
        skip: 1,
      }),
      orderBy: { id: "desc" },
    });

    let nextCursor: number | null = null;
    if (logs.length > take) {
      const nextItem = logs.pop();
      nextCursor = nextItem!.id;
    }

    return createSuccessResponse("Berhasil mengambil whatsapp logs", {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: {
          date_start,
          date_end,
        },
      },
      whatsapp_logs: logs.map(toWhatsappLogEntity),
      next_cursor: nextCursor,
    });
  }

  // ─── GET SUMMARY ─────────────────────────────────────────────────────────

  async getSummary(
    query: GetWhatsappLogsSummaryQuery,
  ): Promise<SuccessResponse<GetWhatsappLogsSummaryResponseData>> {
    const { date_type, start, end } = query;
    const {
      filter: dateFilter,
      date_start,
      date_end,
    } = getWhatsappDateFilter(date_type, start, end);

    const [total, byDeviceRaw, byMessageTypeRaw, byIsGroupRaw, logsRaw] = await Promise.all([
      prisma.whatsappLog.count({ where: dateFilter }),
      prisma.whatsappLog.groupBy({
        by: ["device"],
        where: dateFilter,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["messageType"],
        where: dateFilter,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["isGroup"],
        where: dateFilter,
        _count: { id: true },
      }),
      prisma.whatsappLog.findMany({
        where: dateFilter,
        orderBy: { receivedAt: "asc" },
      }),
    ]);

    const by_device = byDeviceRaw.reduce(
      (acc, curr) => ({ ...acc, [curr.device]: curr._count.id }),
      {} as Record<string, number>,
    );

    const by_message_type = byMessageTypeRaw.reduce(
      (acc, curr) => ({ ...acc, [curr.messageType]: curr._count.id }),
      {} as Record<string, number>,
    );

    const groupCount = byIsGroupRaw.find((x) => x.isGroup)?._count.id || 0;
    const personalCount = byIsGroupRaw.find((x) => !x.isGroup)?._count.id || 0;

    const messagesMap: Record<
      string,
      Record<
        string,
        { sender_name: string | null; messages: ReturnType<typeof toWhatsappLogEntity>[] }
      >
    > = {};

    for (const log of logsRaw) {
      const jakartaDate = toZonedTime(log.receivedAt, "Asia/Jakarta");
      const dateKey = format(jakartaDate, "yyyy-MM-dd");
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

    const messages: Record<
      string,
      {
        sender_name: string | null;
        sender: string;
        messages: ReturnType<typeof toWhatsappLogEntity>[];
      }[]
    > = {};

    for (const [dateKey, senders] of Object.entries(messagesMap)) {
      messages[dateKey] = Object.entries(senders).map(([senderKey, data]) => ({
        sender_name: data.sender_name,
        sender: senderKey,
        messages: data.messages,
      }));
    }

    return createSuccessResponse("Berhasil mengambil summary whatsapp logs", {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: {
          date_start,
          date_end,
        },
      },
      total,
      by_device,
      by_message_type,
      by_chat_type: {
        group: groupCount,
        personal: personalCount,
      },
      messages,
    });
  }
}

export const whatsappLogService = new WhatsappLogService();
