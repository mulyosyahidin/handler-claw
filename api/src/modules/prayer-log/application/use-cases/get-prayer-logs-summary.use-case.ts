import {
  PrayerCategory,
  PrayerMethod,
  PrayerType,
} from "../../../../lib/generated/prisma/enums.js";
import type {
  GetPrayerLogsSummaryQuery,
  GetPrayerLogsSummaryResponse,
  PrayerSummaryEntry,
} from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import { getPrayerDateFilter } from "../../../../utils/date-filter.js";

export class GetPrayerLogsSummaryUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(
    userId: string,
    query: GetPrayerLogsSummaryQuery,
  ): Promise<GetPrayerLogsSummaryResponse> {
    const { date_type, start, end } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const logs = await this.prayerLogRepository.findManySummarized(userId, dateFilter);

    // Group logs by period label
    const grouped = new Map<string, any[]>();

    if (date_start && date_end) {
      const [y1, m1, d1] = date_start.split("-").map(Number) as [number, number, number];
      const [y2, m2, d2] = date_end.split("-").map(Number) as [number, number, number];

      const cur = new Date(Date.UTC(y1, m1 - 1, d1));
      const endObj = new Date(Date.UTC(y2, m2 - 1, d2));

      while (cur <= endObj) {
        grouped.set(this.toISODate(cur), []);
        cur.setUTCDate(cur.getUTCDate() + 1);
      }
    }

    for (const log of logs) {
      const label = this.toISODate(log.date);
      if (!grouped.has(label)) grouped.set(label, []);
      grouped.get(label)!.push(log);
    }

    const summary: PrayerSummaryEntry[] = [];
    const grandCount: Record<string, number> = {};

    for (const p of Object.values(PrayerType)) {
      grandCount[p] = 0;
    }

    let grandWajib = 0;
    let grandSunnah = 0;
    let grandTotal = 0;
    let grandQadha = 0;

    for (const [label, entries] of grouped.entries()) {
      const byPrayer: PrayerSummaryEntry["by_prayer"] = {};
      const curDate = new Date(label);
      const isFriday = curDate.getUTCDay() === 5;

      for (const p of Object.values(PrayerType)) {
        if (p === PrayerType.JUMAT && !isFriday) continue;
        if (p === PrayerType.DZUHUR && isFriday) continue;
        byPrayer[p] = { performed: 0, qadha: 0, jamaah: 0 };
      }

      let wajib = 0;
      let sunnah = 0;
      let qadha = 0;

      for (const e of entries) {
        const key = e.prayer as string;
        grandCount[key] = (grandCount[key] || 0) + 1;

        if (!byPrayer[key]) byPrayer[key] = { performed: 0, qadha: 0, jamaah: 0 };
        byPrayer[key].performed++;
        if (e.is_qadha) {
          byPrayer[key].qadha++;
          qadha++;
        }
        if (e.method === PrayerMethod.JAMAAH) byPrayer[key].jamaah++;

        if (e.category === PrayerCategory.WAJIB) wajib++;
        else sunnah++;
      }

      const total = wajib + sunnah;
      grandWajib += wajib;
      grandSunnah += sunnah;
      grandTotal += total;
      grandQadha += qadha;

      summary.push({
        label,
        total_wajib_performed: wajib,
        total_sunnah_performed: sunnah,
        total_performed: total,
        total_qadha: qadha,
        by_prayer: byPrayer,
      });
    }

    const totalDays = grouped.size || 1;
    let totalFridays = 0;
    for (const label of grouped.keys()) {
      const d = new Date(label);
      if (d.getUTCDay() === 5) totalFridays++;
    }
    const totalNonFridays = totalDays - totalFridays;

    const performances: Record<string, { count: number; percentage?: number }> = {};
    for (const p of Object.values(PrayerType)) {
      const count = grandCount[p] || 0;
      let denominator = totalDays;

      if (p === PrayerType.JUMAT) denominator = totalFridays;
      else if (p === PrayerType.DZUHUR) denominator = totalNonFridays;

      const isSunnah = (
        [PrayerType.DHUHA, PrayerType.TAHAJUD, PrayerType.WITIR] as PrayerType[]
      ).includes(p as PrayerType);

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
}
