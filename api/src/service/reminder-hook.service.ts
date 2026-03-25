import prisma from "../config/prisma.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type {
  GetReminderHooksResponseData,
  ReminderHooksSummaryData,
} from "../lib/types/data/index.js";
import type {
  createReminderHookInput,
  GetReminderHooksQuery,
} from "../lib/schemas/reminder-hook.schema.js";
import { toReminderHookEntity } from "../lib/mappers/index.js";
import { Prisma, type ReminderHook } from "../lib/generated/prisma/client.js";
import { extractImportantHeaders } from "../utils/utils.js";

export class ReminderHookService {
  async createHook(
    userId: string,
    data: createReminderHookInput,
    headers: Record<string, any>,
  ): Promise<ReminderHook> {
    const headersObject = extractImportantHeaders(headers);

    return await prisma.reminderHook.upsert({
      where: {
        userId_eventId: {
          userId,
          eventId: data.event_id,
        },
      },
      update: {
        payloadJson: data as unknown as Prisma.InputJsonValue,
        headersJson: headersObject,
        status: "RECEIVED",
        errorMessage: null,
      },
      create: {
        userId,
        eventId: data.event_id,
        payloadJson: data as unknown as Prisma.InputJsonValue,
        headersJson: headers as unknown as Prisma.InputJsonValue,
        status: "RECEIVED",
      },
    });
  }

  async getHooks(
    userId: string,
    query: GetReminderHooksQuery,
  ): Promise<SuccessResponse<GetReminderHooksResponseData>> {
    const { page, per_page } = query;
    const skip = (page - 1) * per_page;
    const take = per_page;

    const [total, hooks] = await Promise.all([
      prisma.reminderHook.count({ where: { userId } }),
      prisma.reminderHook.findMany({
        where: { userId },
        skip,
        take,
        orderBy: { createdAt: "desc" },
      }),
    ]);

    return createSuccessResponse("Berhasil mengambil daftar reminder hooks", {
      reminder_hooks: hooks.map(toReminderHookEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    });
  }

  async getHooksSummary(userId: string): Promise<SuccessResponse<ReminderHooksSummaryData>> {
    const counts = await prisma.reminderHook.groupBy({
      by: ["status"],
      where: { userId },
      _count: { _all: true },
    });

    const status_counts = {
      received: 0,
      processing: 0,
      processed: 0,
      failed: 0,
    };

    let total = 0;

    for (const item of counts) {
      const count = item._count._all;
      total += count;

      if (item.status === "RECEIVED") status_counts.received = count;
      else if (item.status === "PROCESSING") status_counts.processing = count;
      else if (item.status === "PROCESSED") status_counts.processed = count;
      else if (item.status === "FAILED") status_counts.failed = count;
    }

    return createSuccessResponse("Berhasil mengambil summary reminder hooks", {
      total,
      status_counts,
    });
  }
}

export const reminderHookService = new ReminderHookService();
