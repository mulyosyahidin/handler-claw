import { prisma } from "../../../../config/index.js";
import type { OverviewCounts } from "../../application/dtos/overview.dto.js";
import type { OverviewRepository } from "../../domain/repositories/overview.repository.interface.js";

export class PrismaOverviewRepository implements OverviewRepository {
  async getUserOverviewCounts(userId: string): Promise<OverviewCounts> {
    const [whatsapp_log, prayer_log, notification_webhook, notification, device] =
      await Promise.all([
        prisma.whatsappLog.count(),
        prisma.prayerLog.count({ where: { userId } }),
        prisma.notificationWebhook.count({ where: { userId } }),
        prisma.notification.count({ where: { userId } }),
        prisma.userDevice.count({ where: { userId } }),
      ]);

    return {
      whatsapp_log,
      prayer_log,
      notification_webhook,
      notification,
      device,
    };
  }
}
