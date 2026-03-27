import { prisma } from "../../../../config/index.js";
import type { SystemOverviewCount } from "../../../system/application/dtos/system.dto.js";
import type { OverviewRepository } from "../../domain/repositories/overview.repository.interface.js";

export class PrismaOverviewRepository implements OverviewRepository {
  async getCounts(userId: string): Promise<SystemOverviewCount> {
    const [total_whatsapp_logs, total_prayer_logs, total_reminder_hooks, total_devices] =
      await Promise.all([
        prisma.whatsappLog.count(),
        prisma.prayerLog.count({ where: { userId } }),
        prisma.reminderHook.count({ where: { userId } }),
        prisma.userDevice.count({ where: { userId } }),
      ]);

    return {
      total_whatsapp_logs,
      total_prayer_logs,
      total_reminder_hooks,
      total_devices,
    };
  }
}
