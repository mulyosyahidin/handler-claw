import type {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../../lib/generated/prisma/enums.js";

export type IPrayerLog = {
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
};
