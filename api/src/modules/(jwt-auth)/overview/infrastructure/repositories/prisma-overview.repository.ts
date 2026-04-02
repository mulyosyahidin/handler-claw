import { prisma } from "../../../../../config/index.js";
import { ApiKeyStatus, PrayerType } from "../../../../../lib/generated/prisma/client.js";
import type { OverviewCounts } from "../../application/dtos/overview.dto.js";
import type { OverviewRepository } from "../../domain/repositories/overview.repository.interface.js";

export class PrismaOverviewRepository implements OverviewRepository {
  async getUserOverviewCounts(userId: string): Promise<OverviewCounts> {
    const [whatsapp_log, prayer_log, notification_webhook, notification, device, api_key] =
      await Promise.all([
        prisma.whatsappLog.count({ where: { userId } }),
        prisma.prayerLog.count({ where: { userId } }),
        prisma.notificationWebhook.count({ where: { userId } }),
        prisma.notification.count({ where: { userId } }),
        prisma.userDevice.count({ where: { userId } }),
        prisma.apiKey.count({
          where: { userId, status: ApiKeyStatus.ACTIVE },
        }),
      ]);

    return {
      whatsapp_log,
      prayer_log,
      notification_webhook,
      notification,
      device,
      api_key,
    };
  }

  async getTodayPrayerStatus(userId: string): Promise<Record<string, boolean>> {
    const now = new Date();
    // Zero out time for comparison with the "date" column (@db.Date)
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const isFriday = now.getDay() === 5; // 0 = Sunday, 5 = Friday

    const mandatoryPrayers = [
      PrayerType.SUBUH,
      isFriday ? PrayerType.JUMAT : PrayerType.DZUHUR,
      PrayerType.ASHAR,
      PrayerType.MAGHRIB,
      PrayerType.ISYA,
    ];

    const logs = await prisma.prayerLog.findMany({
      where: {
        userId,
        date: today,
        prayer: { in: mandatoryPrayers },
      },
      select: {
        prayer: true,
        performed: true,
      },
    });

    const status: Record<string, boolean> = {};
    for (const prayer of mandatoryPrayers) {
      status[prayer] = logs.some((l) => l.prayer === prayer);
    }

    return status;
  }
}
