import type { PrayerLog } from "../../domain/entities/prayer-log.entity.js";
import type { PrayerDateType } from "../../../../utils/date-filter.js";
import type {
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../lib/generated/prisma/enums.js";

/**
 * Shared Helper Types
 */
export type PrayerLogFilter = {
  date_type: PrayerDateType;
  start?: string | undefined;
  end?: string | undefined;
  filtered: {
    date_start?: string | undefined;
    date_end?: string | undefined;
  };
};

export type PrayerLogRepositoryFilter = {
  date?: Date | { gte: Date; lte: Date } | undefined;
  performed?: boolean | undefined;
  prayer?: PrayerType | { in: PrayerType[] } | undefined;
};

export type FindAllPrayerLogData = {
  logs: PrayerLog[];
  total: number;
};

/**
 * Request Contracts
 */
export type CreatePrayerLogRequest = {
  prayer: PrayerType;
  local_date?: Date;
  performed_at?: Date;
  method?: PrayerMethod;
  place?: PrayerPlace;
  is_qadha?: boolean;
  notes?: string;
};

export type GetPrayerLogsQuery = {
  page: number;
  per_page: number;
  date_type: PrayerDateType;
  start?: string;
  end?: string;
};

export type GetPrayerLogsSummaryQuery = {
  date_type: PrayerDateType;
  start?: string;
  end?: string;
};

export type DeletePrayerLogParams = {
  id: string;
};

/**
 * Response Contracts
 */
export type CreatePrayerLogResponse = {
  prayer_log: PrayerLog;
};

export type GetPrayerLogsResponse = {
  filter: PrayerLogFilter;
  prayer_logs: PrayerLog[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
};

export type PrayerSummaryEntry = {
  label: string;
  total_wajib_performed: number;
  total_sunnah_performed: number;
  total_performed: number;
  total_qadha: number;
  by_prayer: Record<string, { performed: number; qadha: number; jamaah: number }>;
};

export type GetPrayerLogsSummaryResponse = {
  filter: PrayerLogFilter;
  summary: PrayerSummaryEntry[];
  count: Record<string, number>;
  performances: Record<string, { count: number; percentage?: number }>;
  grand_total: {
    total_wajib_performed: number;
    total_sunnah_performed: number;
    total_performed: number;
    total_qadha: number;
  };
};

export type DeletePrayerLogResponse = {
  success: boolean;
};
