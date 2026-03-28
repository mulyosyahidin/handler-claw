import type { PrayerLog } from "../../../../lib/generated/prisma/client.js";
import type { IPrayerLog } from "../../domain/entities/prayer-log.entity.js";

export function toPrayerLogEntity(data: PrayerLog): IPrayerLog {
  return {
    id: data.id,
    user_id: data.userId,
    date: data.date,
    prayer: data.prayer,
    category: data.category,
    performed: data.performed,
    performed_at: data.performedAt,
    method: data.method,
    place: data.place,
    is_qadha: data.isQadha,
    notes: data.notes,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
