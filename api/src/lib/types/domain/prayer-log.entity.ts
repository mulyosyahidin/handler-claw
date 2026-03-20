import type {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../generated/prisma/enums.js";

/**
 * Domain Entities
 * Representasi data dari database
 */
export interface IPrayerLog {
  id: string;
  user_id: string;
  date: Date;
  prayer: PrayerType;
  category: PrayerCategory;
  performed: boolean;
  performed_at: Date | null;
  method: PrayerMethod | null;
  place: PrayerPlace | null;
  is_qadha: boolean;
  notes: string | null;
  created_at: Date;
  updated_at: Date;
}
