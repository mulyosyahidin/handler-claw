import type { PrayerLog } from "../../../../lib/generated/prisma/client.js";
import type { PrayerLog as Entity } from "../../domain/entities/prayer-log.entity.js";

export function toPrayerLogEntity(p: PrayerLog): Entity {
  return {
    id: p.id,
    user_id: p.userId,
    date: p.date,
    prayer: p.prayer,
    category: p.category,
    performed: p.performed,
    performed_at: p.performedAt,
    method: p.method,
    place: p.place,
    is_qadha: p.isQadha,
    notes: p.notes,
    created_at: p.createdAt,
    updated_at: p.updatedAt,
  };
}
