import prisma from "../config/prisma.js";
import { type OverviewData } from "../lib/types/data/index.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";

export class OverviewService {
  async getOverview(userId: string): Promise<SuccessResponse<OverviewData>> {
    const [total_whatsapp_logs, total_prayer_logs, total_reminder_hooks, total_devices] =
      await Promise.all([
        prisma.whatsappLog.count(),
        prisma.prayerLog.count({ where: { userId } }),
        prisma.reminderHook.count({ where: { userId } }),
        prisma.userDevice.count({ where: { userId } }),
      ]);

    return createSuccessResponse("Berhasil mengambil data overview", {
      count: {
        total_whatsapp_logs,
        total_prayer_logs,
        total_reminder_hooks,
        total_devices,
      },
    });
  }
}

export const overviewService = new OverviewService();
