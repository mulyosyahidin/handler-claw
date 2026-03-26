import { toZonedTime } from "date-fns-tz";
import prisma from "../config/prisma.js";
import {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../lib/generated/prisma/enums.js";
import type {
  GetPrayerLogsQuery,
  GetPrayerLogsSummaryQuery,
  LogPrayerInput,
} from "../lib/schemas/index.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type {
  GetPrayerLogsResponseData,
  GetPrayerLogsSummaryResponseData,
  InsertPrayerLogResponseData,
  PrayerSummaryEntry,
} from "../lib/types/data/prayer-log.types.js";
import { toPrayerLogEntity } from "../lib/mappers/prayer-log.mapper.js";
import { getPrayerDateFilter } from "../lib/utils/prayer-date-filter.js";

export class PrayerLogService {
  async insertLog(
    userId: string,
    data: LogPrayerInput,
  ): Promise<SuccessResponse<InsertPrayerLogResponseData>> {
    const {
      prayer,
      performed_at,
      local_date,
      method = PrayerMethod.SENDIRI,
      place = PrayerPlace.RUMAH,
      is_qadha = false,
      notes,
    } = data;

    // `date` field: simpan sebagai kalender lokal user.
    // Gunakan timezone spesifik agar mendapatkan hari ini berdasarkan timezone (bukan UTC).
    // local_date dari Zod sudah berupa Date object.
    const _ref = local_date ?? performed_at ?? new Date();
    const jakartaDate = toZonedTime(_ref, "Asia/Jakarta");
    const date = new Date(
      Date.UTC(jakartaDate.getFullYear(), jakartaDate.getMonth(), jakartaDate.getDate()),
    );

    // `performedAt`: Prisma menyimpan DateTime sebagai UTC.
    // Jika performed_at kosong, gunakan current time (now) dalam UTC.
    const performedAt: Date = performed_at ? new Date(performed_at) : new Date();

    const wajibPrayers: PrayerType[] = [
      PrayerType.SUBUH,
      PrayerType.DZUHUR,
      PrayerType.ASHAR,
      PrayerType.MAGHRIB,
      PrayerType.ISYA,
      PrayerType.JUMAT,
    ];

    const category = wajibPrayers.includes(prayer) ? PrayerCategory.WAJIB : PrayerCategory.SUNNAH;

    const prayerLog = await prisma.$transaction(async (tx) => {
      // 1. Ambil data eksisting pada HARI KALENDER yang sama
      const existing = await tx.prayerLog.findMany({
        where: {
          userId,
          date,
          prayer: {
            in: [prayer, PrayerType.DZUHUR, PrayerType.JUMAT],
          },
        },
      });

      // 2. Logika Eksklusivitas Jumat/Dzuhur
      if (category === PrayerCategory.WAJIB) {
        if (prayer === PrayerType.JUMAT && existing.some((p) => p.prayer === PrayerType.DZUHUR)) {
          throw new Error("CONFLICT_JUMAT_DZUHUR");
        }
        if (prayer === PrayerType.DZUHUR && existing.some((p) => p.prayer === PrayerType.JUMAT)) {
          throw new Error("CONFLICT_DZUHUR_JUMAT");
        }

        const existingPrayer = existing.find((p) => p.prayer === prayer);

        const baseUpdateData = {
          performed: true,
          performedAt,
          isQadha: is_qadha,
          method,
          place,
          notes: notes ?? null,
          updatedAt: new Date(),
        };

        // 3. Update jika sudah ada (Upsert Logic)
        if (existingPrayer) {
          return await tx.prayerLog.update({
            where: { id: existingPrayer.id },
            data: baseUpdateData,
          });
        }
      }

      // 4. Create New (Untuk Wajib baru atau Sunnah)
      return await tx.prayerLog.create({
        data: {
          userId,
          date,
          prayer,
          category,
          performed: true,
          performedAt,
          isQadha: is_qadha,
          method,
          place,
          notes: notes ?? null,
          updatedAt: new Date(),
        },
      });
    });

    return createSuccessResponse("Berhasil mencatat jurnal solat", {
      prayer_log: toPrayerLogEntity(prayerLog),
    });
  }

  // ─── GET ALL LOGS ──────────────────────────────────────────────────────────

  async getLogs(
    userId: string,
    query: GetPrayerLogsQuery,
  ): Promise<SuccessResponse<GetPrayerLogsResponseData>> {
    const { date_type, start, end, page, per_page } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const limit = per_page;
    const offset = (page - 1) * per_page;

    const [logs, total] = await Promise.all([
      prisma.prayerLog.findMany({
        where: { userId, ...dateFilter },
        orderBy: [{ date: "desc" }, { prayer: "asc" }],
        take: limit,
        skip: offset,
      }),
      prisma.prayerLog.count({
        where: { userId, ...dateFilter },
      }),
    ]);

    return createSuccessResponse("Berhasil mengambil jurnal solat", {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: {
          date_start,
          date_end,
        },
      },
      prayer_logs: logs.map(toPrayerLogEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    });
  }

  // ─── GET SUMMARY ───────────────────────────────────────────────────────────

  async getSummary(
    userId: string,
    query: GetPrayerLogsSummaryQuery,
  ): Promise<SuccessResponse<GetPrayerLogsSummaryResponseData>> {
    const { date_type, start, end } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const logs = await prisma.prayerLog.findMany({
      where: {
        userId,
        performed: true,
        ...dateFilter,
      },
      orderBy: { date: "asc" },
    });

    // Group logs by period label
    const grouped = new Map<string, typeof logs>();

    if (date_start && date_end) {
      // Pre-fill grouped map with all dates in the range
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

    // Build summary entries
    const summary: PrayerSummaryEntry[] = [];
    const grandCount: Record<string, number> = {};

    // Pre-fill grandCount with all valid PrayerTypes so they show up even if 0
    for (const p of Object.values(PrayerType)) {
      grandCount[p] = 0;
    }

    let grandWajib = 0;
    let grandSunnah = 0;
    let grandTotal = 0;
    let grandQadha = 0;

    for (const [label, entries] of grouped.entries()) {
      const byPrayer: PrayerSummaryEntry["by_prayer"] = {};

      // Pre-fill by_prayer with all valid PrayerTypes so they show up even if 0
      for (const p of Object.values(PrayerType)) {
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
        if (e.isQadha) {
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

    // Calculate performances (count and percentage)
    const totalDays = grouped.size || 1;
    const performances: Record<string, { count: number; percentage: number }> = {};
    for (const p of Object.values(PrayerType)) {
      const count = grandCount[p] || 0;
      performances[p] = {
        count,
        percentage: Number(((count / totalDays) * 100).toFixed(2)),
      };
    }

    return createSuccessResponse("Berhasil mengambil ringkasan jurnal solat", {
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
    });
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────

  private toISODate(d: Date): string {
    const pad = (n: number) => n.toString().padStart(2, "0");
    return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
  }
}

export const prayerLogService = new PrayerLogService();
