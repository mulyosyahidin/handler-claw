import {
  addDays,
  format,
  startOfISOWeek,
  startOfMonth,
  startOfYear,
  subDays,
  subYears,
} from "date-fns";
import { toZonedTime } from "date-fns-tz";
import type { Prisma } from "../lib/generated/prisma/client.js";

const TZ = "Asia/Jakarta";

/**
 * Shared internal helpers
 */
function parseLocalDateString(dateStr: string): Date {
  const [year = 0, month = 1, day = 1] = dateStr.split("-").map(Number);
  return new Date(Date.UTC(year, month - 1, day));
}

/**
 * Common Date Type
 */
export type DateFilterType =
  | "today"
  | "this_week"
  | "this_month"
  | "this_year"
  | "7_days"
  | "30_days"
  | "1_year"
  | "all"
  | "custom";

// Backward compatibility aliases
export type PrayerDateType = DateFilterType;
export type WhatsappDateType = DateFilterType;

/**
 * Prayer Date Filter Logic
 * (Specifically for fields stored as UTC Midnight)
 */

export type PrayerDateFilter = {
  date?: Prisma.DateTimeFilter;
};

export interface PrayerDateFilterResult {
  filter: PrayerDateFilter;
  date_start?: string;
  date_end?: string;
}

export function getPrayerDateFilter(
  dateType: DateFilterType,
  customStart?: string,
  customEnd?: string,
): PrayerDateFilterResult {
  const nowUtc = new Date();
  const jakartaNow = toZonedTime(nowUtc, TZ);

  // helper: convert local date → UTC midnight
  const toUtcMidnightFromLocal = (date: Date) => {
    return new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0));
  };

  const todayLocal = new Date(
    jakartaNow.getFullYear(),
    jakartaNow.getMonth(),
    jakartaNow.getDate(),
  );

  const tomorrowLocal = addDays(todayLocal, 1);

  const todayStr = format(todayLocal, "yyyy-MM-dd");

  switch (dateType) {
    case "today": {
      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(todayLocal),
            lt: toUtcMidnightFromLocal(tomorrowLocal),
          },
        },
        date_start: todayStr,
        date_end: todayStr,
      };
    }

    case "this_week": {
      const startLocal = startOfISOWeek(todayLocal);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "this_month": {
      const startLocal = startOfMonth(todayLocal);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "this_year": {
      const startLocal = startOfYear(todayLocal);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "7_days": {
      const startLocal = subDays(todayLocal, 6);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "30_days": {
      const startLocal = subDays(todayLocal, 29);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "1_year": {
      const startLocal = subYears(todayLocal, 1);
      const endLocal = tomorrowLocal;

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(endLocal),
          },
        },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "custom": {
      if (!customStart || !customEnd) {
        throw new Error("custom_start and custom_end are required for date_type 'custom'");
      }

      const startLocal = parseLocalDateString(customStart);
      const endLocal = parseLocalDateString(customEnd);

      return {
        filter: {
          date: {
            gte: toUtcMidnightFromLocal(startLocal),
            lt: toUtcMidnightFromLocal(addDays(endLocal, 1)),
          },
        },
        date_start: customStart,
        date_end: customEnd,
      };
    }

    case "all":
    default:
      return { filter: {} };
  }
}
