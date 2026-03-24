import type { IPrayerLog } from "../domain/index.js";

export interface InsertPrayerLogResponseData {
  prayer_log: IPrayerLog;
}

export interface GetPrayerLogsResponseData {
  prayer_logs: IPrayerLog[];
  total: number;
}

export type SummaryType = "daily" | "weekly" | "monthly" | "yearly" | "all" | "custom";

export interface PrayerSummaryEntry {
  label: string;
  total_wajib_performed: number;
  total_sunnah_performed: number;
  total_performed: number;
  total_qadha: number;
  by_prayer: Record<string, { performed: number; qadha: number; jamaah: number }>;
}

export interface GetPrayerLogsSummaryResponseData {
  type: SummaryType;
  start_date: string | null;
  end_date: string | null;
  summary: PrayerSummaryEntry[];
  grand_total: {
    total_wajib_performed: number;
    total_sunnah_performed: number;
    total_performed: number;
    total_qadha: number;
  };
}
