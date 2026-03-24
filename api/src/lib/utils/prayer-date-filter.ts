import { format, startOfISOWeek, startOfMonth, startOfYear, subDays, subYears } from "date-fns";
import { toZonedTime } from "date-fns-tz";

const TZ = "Asia/Jakarta";

/**
 * Convert a `Date` (in any timezone context) to a pure UTC midnight `Date`
 * whose year/month/day matches the **Jakarta local date** of the input.
 *
 * e.g. 2026-03-23T00:00:00+07:00  →  new Date("2026-03-23T00:00:00.000Z")
 */
function toUtcMidnight(date: Date): Date {
  const jakarta = toZonedTime(date, TZ);
  return new Date(Date.UTC(jakarta.getFullYear(), jakarta.getMonth(), jakarta.getDate()));
}

/**
 * Parse a 'YYYY-MM-DD' string as UTC midnight directly.
 * Input is already a local calendar date, so no timezone conversion needed.
 */
function parseLocalDateString(dateStr: string): Date {
  const [year = 0, month = 1, day = 1] = dateStr.split("-").map(Number);
  return new Date(Date.UTC(year, month - 1, day));
}

export type PrayerDateType =
  | "today"
  | "this_week"
  | "this_month"
  | "this_year"
  | "7_days"
  | "30_days"
  | "1_year"
  | "all"
  | "custom";

export type PrayerDateFilter =
  | { date: Date }
  | { date: { gte: Date; lte: Date } }
  | Record<string, never>;

export interface PrayerDateFilterResult {
  filter: PrayerDateFilter;
  date_start?: string;
  date_end?: string;
}

/**
 * Returns a Prisma `where` fragment targeting only the `date` column,
 * along with the calculated `date_start` and `date_end` (YYYY-MM-DD).
 *
 * All `date` values in `prayer_logs` are stored as UTC midnight
 * (e.g. `2026-03-23T00:00:00.000Z`), so filters must match the same format.
 *
 * @param dateType  - One of the supported period keys.
 * @param customStart - 'YYYY-MM-DD' inclusive start (only for 'custom').
 * @param customEnd   - 'YYYY-MM-DD' inclusive end   (only for 'custom').
 */
export function getPrayerDateFilter(
  dateType: PrayerDateType,
  customStart?: string,
  customEnd?: string,
): PrayerDateFilterResult {
  // "now" in Jakarta — used as the anchor for all relative calculations.
  const nowUtc = new Date();
  const jakartaNow = toZonedTime(nowUtc, TZ);
  const today = toUtcMidnight(nowUtc);
  const todayStr = format(jakartaNow, "yyyy-MM-dd");

  switch (dateType) {
    // ── Exact day ────────────────────────────────────────────────────────────
    case "today":
      return { filter: { date: today }, date_start: todayStr, date_end: todayStr };

    // ── ISO Week (Mon – today) ───────────────────────────────────────────────
    case "this_week": {
      const weekStartLocal = startOfISOWeek(jakartaNow);
      const weekStart = toUtcMidnight(weekStartLocal);
      return {
        filter: { date: { gte: weekStart, lte: today } },
        date_start: format(weekStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Calendar month (1st – today) ─────────────────────────────────────────
    case "this_month": {
      const monthStartLocal = startOfMonth(jakartaNow);
      const monthStart = toUtcMidnight(monthStartLocal);
      return {
        filter: { date: { gte: monthStart, lte: today } },
        date_start: format(monthStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Calendar year (Jan 1 – today) ────────────────────────────────────────
    case "this_year": {
      const yearStartLocal = startOfYear(jakartaNow);
      const yearStart = toUtcMidnight(yearStartLocal);
      return {
        filter: { date: { gte: yearStart, lte: today } },
        date_start: format(yearStartLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Rolling 7 days (today − 6 days → today) ──────────────────────────────
    case "7_days": {
      const startLocal = subDays(jakartaNow, 6);
      const start = toUtcMidnight(subDays(nowUtc, 6));
      return {
        filter: { date: { gte: start, lte: today } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Rolling 30 days (today − 29 days → today) ────────────────────────────
    case "30_days": {
      const startLocal = subDays(jakartaNow, 29);
      const start = toUtcMidnight(subDays(nowUtc, 29));
      return {
        filter: { date: { gte: start, lte: today } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Rolling 1 year (today − 1 year → today) ──────────────────────────────
    case "1_year": {
      const startLocal = subYears(jakartaNow, 1);
      const start = toUtcMidnight(subYears(nowUtc, 1));
      return {
        filter: { date: { gte: start, lte: today } },
        date_start: format(startLocal, "yyyy-MM-dd"),
        date_end: todayStr,
      };
    }

    // ── Custom range ─────────────────────────────────────────────────────────
    case "custom": {
      if (!customStart || !customEnd) {
        throw new Error("custom_start and custom_end are required for date_type 'custom'");
      }
      const start = parseLocalDateString(customStart);
      const end = parseLocalDateString(customEnd);
      return {
        filter: { date: { gte: start, lte: end } },
        date_start: customStart,
        date_end: customEnd,
      };
    }

    // ── All time (no filter) ──────────────────────────────────────────────────
    case "all":
    default:
      return { filter: {} };
  }
}
