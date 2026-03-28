import type {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../lib/generated/prisma/client.js";
import type { IPrayerLog } from "../../domain/entities/prayer-log.entity.js";
import type { PaginationMetaDto } from "../../../../lib/types/pagination-meta-dto.js";

/**
 * Input Data Contracts
 */
export type CreatePrayerLogRequest = {
  prayer: PrayerType;
  local_date?: Date;
  performed_at?: Date;
  method?: PrayerMethod;
  place?: PrayerPlace;
  is_qadha: boolean;
  notes?: string;
};

export type CreatePrayerLogData = {
  userId: string;
  date: Date;
  prayer: PrayerType;
  performed: boolean;
  performedAt?: Date | null;
  category: PrayerCategory;
  method?: PrayerMethod | null;
  place?: PrayerPlace;
  isQadha?: boolean;
  notes?: string | null;
};

export type UpdatePrayerLogData = {
  performed?: boolean;
  performedAt?: Date | null;
  category?: PrayerCategory;
  method?: PrayerMethod | null;
  place?: PrayerPlace;
  isQadha?: boolean;
  notes?: string | null;
};

export type GetPrayerLogsQuery = {
  page: number;
  per_page: number;
  date_type:
    | "today"
    | "this_week"
    | "this_month"
    | "this_year"
    | "7_days"
    | "30_days"
    | "1_year"
    | "all"
    | "custom";
  start?: string;
  end?: string;
};

export type GetPrayerLogsSummaryQuery = {
  date_type:
    | "today"
    | "this_week"
    | "this_month"
    | "this_year"
    | "7_days"
    | "30_days"
    | "1_year"
    | "all"
    | "custom";
  start?: string;
  end?: string;
};

/**
 * Filter Contracts
 */
export type DateRangeFilter = {
  gte?: Date | string;
  lte?: Date | string;
  gt?: Date | string;
  lt?: Date | string;
};

export type PrayerLogRepositoryFilter = {
  date?: DateRangeFilter;
  performed?: boolean;
  prayer?: PrayerType;
};

export type ByPrayer = Record<
  PrayerType,
  {
    performed: number;
    qadha: number;
    jamaah: number;
  }
>;

export type PrayerSummaryEntry = {
  label: string;
  total_wajib_performed: number;
  total_sunnah_performed: number;
  total_performed: number;
  total_qadha: number;
  by_prayer: ByPrayer;
};

/**
 * Response Contracts
 */
export type CreatePrayerLogResponse = {
  prayer_log: IPrayerLog;
};

export type GetPrayerLogsResponse = {
  filter: {
    date_type: string;
    start?: string | undefined;
    end?: string | undefined;
    filtered?: {
      date_start?: string | undefined;
      date_end?: string | undefined;
    };
  };
  prayer_logs: IPrayerLog[];
  meta: PaginationMetaDto;
};

export type GetPrayerLogsSummaryResponse = {
  filter: {
    date_type: string;
    start?: string | undefined;
    end?: string | undefined;
    filtered?: {
      date_start?: string | undefined;
      date_end?: string | undefined;
    };
  };
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
