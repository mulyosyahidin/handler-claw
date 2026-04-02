import {
  PrayerCategory,
  PrayerMethod,
  PrayerType,
} from "../../../../../lib/generated/prisma/enums.js";
import type {
  ByPrayer,
  GetPrayerLogsSummaryQuery,
  GetPrayerLogsSummaryResponse,
  PrayerSummaryEntry,
} from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import { getPrayerDateFilter } from "../../../../../utils/date-filter.js";

export class GetPrayerLogsSummaryUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(
    userId: string,
    query: GetPrayerLogsSummaryQuery,
  ): Promise<GetPrayerLogsSummaryResponse> {
    const { date_type, start, end } = query;

    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const rows = await this.prayerLogRepository.findSummary(userId, dateFilter);

    const grouped = new Map<string, PrayerSummaryEntry>();

    // 🔥 init range
    if (date_start && date_end) {
      const [y1, m1, d1] = this.parseYMD(date_start);
      const [y2, m2, d2] = this.parseYMD(date_end);

      const cur = new Date(Date.UTC(y1, m1 - 1, d1));
      const endObj = new Date(Date.UTC(y2, m2 - 1, d2));

      while (cur <= endObj) {
        const label = this.toISODate(cur);

        grouped.set(label, {
          label,
          total_wajib_performed: 0,
          total_sunnah_performed: 0,
          total_performed: 0,
          total_qadha: 0,
          by_prayer: this.initByPrayer(),
        });

        cur.setUTCDate(cur.getUTCDate() + 1);
      }
    }

    // 🔥 grand totals
    const grandCount: Record<PrayerType, number> = {} as any;
    for (const p of Object.values(PrayerType)) {
      grandCount[p] = 0;
    }

    let grandWajib = 0;
    let grandSunnah = 0;
    let grandTotal = 0;
    let grandQadha = 0;

    // 🔥 process rows
    for (const row of rows) {
      const label = this.toISODate(new Date(row.date));
      const key = row.prayer as PrayerType;
      const count = Number(row.count);

      if (!grouped.has(label)) {
        grouped.set(label, {
          label,
          total_wajib_performed: 0,
          total_sunnah_performed: 0,
          total_performed: 0,
          total_qadha: 0,
          by_prayer: this.initByPrayer(),
        });
      }

      const entry = grouped.get(label)!;

      // ✅ core logic (tidak boleh dihapus)
      entry.by_prayer[key].performed += count;

      if (row.is_qadha) {
        entry.by_prayer[key].qadha += count;
        entry.total_qadha += count;
        grandQadha += count;
      }

      if (row.method === PrayerMethod.JAMAAH) {
        entry.by_prayer[key].jamaah += count;
      }

      if (row.category === PrayerCategory.WAJIB) {
        entry.total_wajib_performed += count;
        grandWajib += count;
      } else {
        entry.total_sunnah_performed += count;
        grandSunnah += count;
      }

      entry.total_performed += count;
      grandTotal += count;

      grandCount[key] += count;
    }

    // 🔥 sort result (important)
    const summary = Array.from(grouped.values()).sort((a, b) => a.label.localeCompare(b.label));

    const totalDays = summary.length || 1;

    let totalFridays = 0;
    for (const s of summary) {
      const d = new Date(s.label);
      if (d.getUTCDay() === 5) totalFridays++;
    }

    const totalNonFridays = totalDays - totalFridays;

    const SUNNAH_PRAYERS = new Set<PrayerType>([
      PrayerType.DHUHA,
      PrayerType.TAHAJUD,
      PrayerType.WITIR,
    ]);

    const performances: Record<PrayerType, { count: number; percentage?: number }> = {} as any;

    for (const p of Object.values(PrayerType)) {
      const count = grandCount[p] || 0;

      let denominator = totalDays;

      if (p === PrayerType.JUMAT) denominator = totalFridays;
      else if (p === PrayerType.DZUHUR) denominator = totalNonFridays;

      const isSunnah = SUNNAH_PRAYERS.has(p);

      performances[p] = {
        count,
        ...(isSunnah
          ? {}
          : {
              percentage: Number(((count / (denominator || 1)) * 100).toFixed(2)),
            }),
      };
    }

    return {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: {
          date_start,
          date_end,
        },
      },
      summary,
      count: grandCount,
      performances,
      grand_total: {
        total_wajib_performed: grandWajib,
        total_sunnah_performed: grandSunnah,
        total_performed: grandTotal,
        total_qadha: grandQadha,
      },
    };
  }

  private toISODate(d: Date): string {
    const pad = (n: number) => n.toString().padStart(2, "0");
    return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
  }

  private parseYMD(dateStr: string): [number, number, number] {
    const parts = dateStr.split("-");
    if (parts.length !== 3) throw new Error("Invalid date format");

    const y = Number(parts[0]);
    const m = Number(parts[1]);
    const d = Number(parts[2]);

    if ([y, m, d].some(Number.isNaN)) {
      throw new Error("Invalid date value");
    }

    return [y, m, d];
  }

  private initByPrayer(): ByPrayer {
    const result = {} as ByPrayer;

    for (const p of Object.values(PrayerType)) {
      result[p] = {
        performed: 0,
        qadha: 0,
        jamaah: 0,
      };
    }

    return result;
  }
}
