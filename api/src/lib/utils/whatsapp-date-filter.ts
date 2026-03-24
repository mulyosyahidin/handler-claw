import { format, startOfISOWeek, startOfMonth, startOfYear, subDays, subYears } from "date-fns";
import { toZonedTime } from "date-fns-tz";

const TZ = "Asia/Jakarta";

function toUtcMidnight(date: Date): Date {
  const jakarta = toZonedTime(date, TZ);
  return new Date(Date.UTC(jakarta.getFullYear(), jakarta.getMonth(), jakarta.getDate()));
}

function parseLocalDateString(dateStr: string): Date {
  const [year = 0, month = 1, day = 1] = dateStr.split("-").map(Number);
  return new Date(Date.UTC(year, month - 1, day));
}

export type WhatsappDateType =
  | "today"
  | "this_week"
  | "this_month"
  | "this_year"
  | "7_days"
  | "30_days"
  | "1_year"
  | "all"
  | "custom";

export type WhatsappDateFilter = { receivedAt: { gte: Date; lt: Date } } | Record<string, never>;

export interface WhatsappDateFilterResult {
  filter: WhatsappDateFilter;
  date_start?: string;
  date_end?: string;
}

export function getWhatsappDateFilter(
  dateType: WhatsappDateType,
  customStart?: string,
  customEnd?: string,
): WhatsappDateFilterResult {
  const nowUtc = new Date();
  const jakartaNow = toZonedTime(nowUtc, TZ);
  const today = toUtcMidnight(nowUtc);
  const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
  const todayStr = format(jakartaNow, "yyyy-MM-dd");

  switch (dateType) {
    case "today":
      return {
        filter: { receivedAt: { gte: today, lt: tomorrow } },
        date_start: todayStr,
        date_end: todayStr,
      };

    case "this_week": {
      const weekStartLocal = startOfISOWeek(jakartaNow);
      const weekStart = toUtcMidnight(weekStartLocal);
      return {
        filter: { receivedAt: { gte: weekStart, lt: tomorrow } },
        date_start: format(weekStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "this_month": {
      const monthStartLocal = startOfMonth(jakartaNow);
      const monthStart = toUtcMidnight(monthStartLocal);
      return {
        filter: { receivedAt: { gte: monthStart, lt: tomorrow } },
        date_start: format(monthStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "this_year": {
      const yearStartLocal = startOfYear(jakartaNow);
      const yearStart = toUtcMidnight(yearStartLocal);
      return {
        filter: { receivedAt: { gte: yearStart, lt: tomorrow } },
        date_start: format(yearStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "7_days": {
      const startLocal = subDays(jakartaNow, 6);
      const start = toUtcMidnight(subDays(nowUtc, 6));
      return {
        filter: { receivedAt: { gte: start, lt: tomorrow } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "30_days": {
      const startLocal = subDays(jakartaNow, 29);
      const start = toUtcMidnight(subDays(nowUtc, 29));
      return {
        filter: { receivedAt: { gte: start, lt: tomorrow } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "1_year": {
      const startLocal = subYears(jakartaNow, 1);
      const start = toUtcMidnight(subYears(nowUtc, 1));
      return {
        filter: { receivedAt: { gte: start, lt: tomorrow } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    case "custom": {
      if (!customStart || !customEnd) {
        throw new Error("custom_start and custom_end are required for date_type 'custom'");
      }
      const start = parseLocalDateString(customStart);
      const end = parseLocalDateString(customEnd);
      const endNextDay = new Date(end.getTime() + 24 * 60 * 60 * 1000);
      return {
        filter: { receivedAt: { gte: start, lt: endNextDay } },
        date_start: customStart,
        date_end: customEnd,
      };
    }

    case "all":
    default:
      return { filter: {} };
  }
}
