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
    const { cursor, take, device, sender, is_group } = query;

    const logs = await prisma.whatsappLog.findMany({
      take: take + 1, // Ambil satu ekstra untuk menentukan apakah ada halaman berikutnya
      ...(cursor !== undefined && {
        cursor: { id: cursor },
        skip: 1, // Lewati item yang menjadi cursor
      }),
      where: {
        ...(device !== undefined && { device }),
        ...(sender !== undefined && { sender }),
        ...(is_group !== undefined && { isGroup: is_group }),
      },
      orderBy: { id: "desc" },
    });

    // Tentukan cursor berikutnya
    let nextCursor: number | null = null;
    if (logs.length > take) {
      const nextItem = logs.pop(); // Hapus item ekstra
      nextCursor = nextItem!.id;
    }

    return createSuccessResponse("Berhasil mengambil whatsapp logs", {
      whatsapp_logs: logs.map(toWhatsappLogEntity),
      next_cursor: nextCursor,
    });
  }

  // ─── GET SUMMARY ─────────────────────────────────────────────────────────

  async getSummary(
    query: GetWhatsappLogsSummaryQuery,
  ): Promise<SuccessResponse<GetWhatsappLogsSummaryResponseData>> {
    const { device, start_date, end_date } = query;

    const whereClause: Prisma.WhatsappLogWhereInput = {
      ...(device !== undefined && { device }),
      ...((start_date || end_date) && {
        receivedAt: {
          ...(start_date && { gte: new Date(start_date) }),
          ...(end_date && { lte: new Date(end_date) }),
        },
      }),
    };

    const [total, byDeviceRaw, byMessageTypeRaw, byIsGroupRaw] = await Promise.all([
      prisma.whatsappLog.count({ where: whereClause }),
      prisma.whatsappLog.groupBy({
        by: ["device"],
        where: whereClause,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["messageType"],
        where: whereClause,
        _count: { id: true },
      }),
      prisma.whatsappLog.groupBy({
        by: ["isGroup"],
        where: whereClause,
        _count: { id: true },
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

    return createSuccessResponse("Berhasil mengambil summary whatsapp logs", {
      total,
      by_device,
      by_message_type,
      by_chat_type: {
        group: groupCount,
        personal: personalCount,
      },
    });
  }
}

export const whatsappLogService = new WhatsappLogService();
