import type { PrayerLog } from "../generated/prisma/client.js";
import type { IPrayerLog } from "../types/domain/index.js";

export function toPrayerLogEntity(prismaPrayerLog: PrayerLog): IPrayerLog {
  return {
    id: prismaPrayerLog.id,
    user_id: prismaPrayerLog.userId,
    date: prismaPrayerLog.date,
    prayer: prismaPrayerLog.prayer,
    category: prismaPrayerLog.category,
    performed: prismaPrayerLog.performed,
    performed_at: prismaPrayerLog.performedAt,
    method: prismaPrayerLog.method,
    place: prismaPrayerLog.place,
    is_qadha: prismaPrayerLog.isQadha,
    notes: prismaPrayerLog.notes,
    created_at: prismaPrayerLog.createdAt,
    updated_at: prismaPrayerLog.updatedAt,
  };
}
