import prisma from "../config/prisma.js";
import {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../lib/generated/prisma/enums.js";
import type { LogPrayerInput } from "../lib/schemas/index.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type {
  GetPrayerLogsResponseData,
  GetPrayerLogsSummaryResponseData,
  InsertPrayerLogResponseData,
  PrayerSummaryEntry,
  SummaryType,
} from "../lib/types/data/prayer-log.types.js";
import { toPrayerLogEntity } from "../lib/mappers/prayer-log.mapper.js";

export class PrayerLogService {
  async insertLog(
    userId: string,
    data: LogPrayerInput,
  ): Promise<SuccessResponse<InsertPrayerLogResponseData>> {
    const {
      prayer,
      performed_at,
      method = PrayerMethod.SENDIRI,
      place = PrayerPlace.RUMAH,
      is_qadha,
      notes,
    } = data;

    // Normalisasi waktu pelaksanaan dan turunkan nilai tanggal (awal hari)
    const performedAt = performed_at ?? new Date();
    const date = new Date(performedAt);
    date.setHours(0, 0, 0, 0);

    // Menentukan kategori salat (WAJIB atau SUNNAH)
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
      // Mengambil data salat relevan pada hari yang sama untuk kebutuhan validasi aturan
      const existing = await tx.prayerLog.findMany({
        where: {
          userId,
          date,
          prayer: {
            in: [prayer, PrayerType.DZUHUR, PrayerType.JUMAT],
          },
        },
      });

      // Menjaga aturan eksklusivitas antara salat Jumat dan Dzuhur
      if (category === PrayerCategory.WAJIB) {
        if (prayer === PrayerType.JUMAT) {
          const hasDzuhur = existing.some((p) => p.prayer === PrayerType.DZUHUR);
          if (hasDzuhur) {
            throw new Error("CONFLICT_JUMAT_DZUHUR");
          }
        }

        if (prayer === PrayerType.DZUHUR) {
          const hasJumat = existing.some((p) => p.prayer === PrayerType.JUMAT);
          if (hasJumat) {
            throw new Error("CONFLICT_DZUHUR_JUMAT");
          }
        }

        const existingPrayer = existing.find((p) => p.prayer === prayer);

        // Menyusun data update dengan mengabaikan field yang tidak dikirim (undefined)
        const baseData = {
          performed: true,
          performedAt,
          isQadha: is_qadha,
          ...(method !== undefined && { method }),
          ...(place !== undefined && { place }),
          ...(notes !== undefined && { notes }),
        };

        // Update jika data salat sudah ada sebelumnya
        if (existingPrayer) {
          return await tx.prayerLog.update({
            where: { id: existingPrayer.id },
            data: baseData,
          });
        }

        // Insert jika belum ada data untuk salat tersebut di hari yang sama
        return await tx.prayerLog.create({
          data: {
            userId,
            date,
            prayer,
            category,
            ...baseData,
          },
        });
      }

      // Salat sunnah tidak memiliki batasan unik, sehingga selalu dibuat sebagai data baru
      return await tx.prayerLog.create({
        data: {
          userId,
          date,
          prayer,
          category,
          performed: true,
          performedAt,
          isQadha: is_qadha,
          ...(method !== undefined && { method }),
          ...(place !== undefined && { place }),
          ...(notes !== undefined && { notes }),
        },
      });
    });

    return createSuccessResponse("Berhasil mencatat jurnal solat", {
      prayer_log: toPrayerLogEntity(prayerLog),
    });
  }

  // ─── GET ALL LOGS ──────────────────────────────────────────────────────────

  async getLogs(userId: string): Promise<SuccessResponse<GetPrayerLogsResponseData>> {
    const logs = await prisma.prayerLog.findMany({
      where: { userId },
      orderBy: [{ date: "desc" }, { createdAt: "desc" }],
    });

    return createSuccessResponse("Berhasil mengambil jurnal solat", {
      prayer_logs: logs.map(toPrayerLogEntity),
      total: logs.length,
    });
  }

  // ─── GET SUMMARY ───────────────────────────────────────────────────────────

  async getSummary(
    userId: string,
    type: SummaryType,
    startDate?: Date,
    endDate?: Date,
  ): Promise<SuccessResponse<GetPrayerLogsSummaryResponseData>> {
    const now = new Date();

    // Resolve date range
    let rangeStart: Date | undefined;
    let rangeEnd: Date | undefined;

    switch (type) {
      case "daily":
        rangeStart = new Date(now);
        rangeStart.setHours(0, 0, 0, 0);
        rangeEnd = new Date(now);
        rangeEnd.setHours(23, 59, 59, 999);
        break;
      case "weekly": {
        // Monday as first day of week
        const day = now.getDay();
        const diffToMonday = day === 0 ? -6 : 1 - day;
        rangeStart = new Date(now);
        rangeStart.setDate(now.getDate() + diffToMonday);
        rangeStart.setHours(0, 0, 0, 0);
        rangeEnd = new Date(rangeStart);
        rangeEnd.setDate(rangeStart.getDate() + 6);
        rangeEnd.setHours(23, 59, 59, 999);
        break;
      }
      case "monthly":
        rangeStart = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
        rangeEnd = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
        break;
      case "yearly":
        rangeStart = new Date(now.getFullYear(), 0, 1, 0, 0, 0, 0);
        rangeEnd = new Date(now.getFullYear(), 11, 31, 23, 59, 59, 999);
        break;
      case "all":
        rangeStart = undefined;
        rangeEnd = undefined;
        break;
      case "custom":
        if (!startDate || !endDate) {
          throw new Error("CUSTOM_RANGE_REQUIRED");
        }
        rangeStart = new Date(startDate);
        rangeStart.setHours(0, 0, 0, 0);
        rangeEnd = new Date(endDate);
        rangeEnd.setHours(23, 59, 59, 999);
        break;
    }

    const logs = await prisma.prayerLog.findMany({
      where: {
        userId,
        ...(rangeStart && rangeEnd ? { date: { gte: rangeStart, lte: rangeEnd } } : {}),
        performed: true,
      },
      orderBy: { date: "asc" },
    });

    // Group logs by period label
    const grouped = new Map<string, typeof logs>();

    for (const log of logs) {
      const label = this.periodLabel(log.date, type);
      if (!grouped.has(label)) grouped.set(label, []);
      grouped.get(label)!.push(log);
    }

    // Build summary entries
    const summary: PrayerSummaryEntry[] = [];
    let grandWajib = 0;
    let grandSunnah = 0;
    let grandTotal = 0;
    let grandQadha = 0;

    for (const [label, entries] of grouped.entries()) {
      const byPrayer: PrayerSummaryEntry["by_prayer"] = {};
      let wajib = 0;
      let sunnah = 0;
      let qadha = 0;

      for (const e of entries) {
        const key = e.prayer as string;
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

    const startLabel = type === "all" || !rangeStart ? null : this.toISODate(rangeStart);
    const endLabel = type === "all" || !rangeEnd ? null : this.toISODate(rangeEnd);

    return createSuccessResponse("Berhasil mengambil ringkasan jurnal solat", {
      type,
      start_date: startLabel,
      end_date: endLabel,
      summary,
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
    return d.toISOString().split("T")[0] ?? "";
  }

  private periodLabel(date: Date, type: SummaryType): string {
    switch (type) {
      case "daily":
        return this.toISODate(date);
      case "weekly": {
        // ISO week label: YYYY-Www
        const tmp = new Date(date);
        tmp.setHours(0, 0, 0, 0);
        tmp.setDate(tmp.getDate() + 3 - ((tmp.getDay() + 6) % 7));
        const week1 = new Date(tmp.getFullYear(), 0, 4);
        const weekNum =
          Math.round(
            ((tmp.getTime() - week1.getTime()) / 86400000 + ((week1.getDay() + 6) % 7)) / 7,
          ) + 1;
        return `${tmp.getFullYear()}-W${String(weekNum).padStart(2, "0")}`;
      }
      case "monthly":
        return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}`;
      case "yearly":
        return `${date.getFullYear()}`;
      case "all":
      case "custom":
        // group by date
        return this.toISODate(date);
    }
  }
}

export const prayerLogService = new PrayerLogService();
