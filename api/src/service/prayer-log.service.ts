import prisma from "../config/prisma.js";
import {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../lib/generated/prisma/enums.js";
import type { LogPrayerInput } from "../lib/schemas/index.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type { InsertPrayerLogResponseData } from "../lib/types/data/prayer-log.types.js";
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
}

export const prayerLogService = new PrayerLogService();
