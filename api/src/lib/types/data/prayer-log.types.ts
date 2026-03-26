import type { IPrayerLog } from "../domain/index.js";

import type { PrayerDateType } from "../../utils/prayer-date-filter.js";

export interface InsertPrayerLogResponseData {
  prayer_log: IPrayerLog;
}

export interface PrayerLogFilterData {
  date_type: PrayerDateType;
  start?: string | undefined;
  end?: string | undefined;
  filtered: {
    date_start?: string | undefined;
    date_end?: string | undefined;
  };
}

export interface GetPrayerLogsResponseData {
  filter: PrayerLogFilterData;
  prayer_logs: IPrayerLog[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
}

export interface PrayerSummaryEntry {
  label: string;
  total_wajib_performed: number;
  total_sunnah_performed: number;
  total_performed: number;
  total_qadha: number;
  by_prayer: Record<string, { performed: number; qadha: number; jamaah: number }>;
}

export interface GetPrayerLogsSummaryResponseData {
  filter: PrayerLogFilterData;
  summary: PrayerSummaryEntry[];
  count: Record<string, number>;
  performances: Record<string, { count: number; percentage: number }>;
  grand_total: {
    total_wajib_performed: number;
    total_sunnah_performed: number;
    total_performed: number;
    total_qadha: number;
  };
}
