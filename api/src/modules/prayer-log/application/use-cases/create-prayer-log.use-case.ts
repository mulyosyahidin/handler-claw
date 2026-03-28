import { toZonedTime } from "date-fns-tz";
import {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../lib/generated/prisma/enums.js";
import type { CreatePrayerLogRequest, CreatePrayerLogResponse } from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import { toPrayerLogEntity } from "../../infrastructure/mappers/prayer-log.mapper.js";
import { BadRequestError } from "../../../../lib/errors/bad-request.error.js";
import type { PrayerLog } from "../../../../lib/generated/prisma/client.js";

export class CreatePrayerLogUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(userId: string, data: CreatePrayerLogRequest): Promise<CreatePrayerLogResponse> {
    const { prayer, performed_at, local_date, is_qadha = false, notes } = data;

    // 1. Resolve waktu
    const reference = local_date ?? performed_at ?? new Date();
    const jakartaDate = toZonedTime(reference, "Asia/Jakarta");

    // date = LOCAL (Jakarta, disimpan sebagai UTC midnight)
    const date = new Date(
      Date.UTC(jakartaDate.getFullYear(), jakartaDate.getMonth(), jakartaDate.getDate()),
    );

    // performedAt = UTC (real timestamp)
    const performedAt: Date = performed_at ? new Date(performed_at) : new Date();

    // 2. Resolve method & place
    const method =
      data.method ?? (prayer === PrayerType.JUMAT ? PrayerMethod.JAMAAH : PrayerMethod.SENDIRI);

    const place =
      data.place ?? (prayer === PrayerType.JUMAT ? PrayerPlace.MASJID : PrayerPlace.RUMAH);

    // 3. Resolve category
    const category = this.resolveCategory(prayer, jakartaDate);

    // 4. Ambil existing (untuk konflik & upsert)
    const existing = await this.prayerLogRepository.findByUserDateAndPrayers(userId, date, [
      prayer,
      PrayerType.DZUHUR,
      PrayerType.JUMAT,
    ]);

    // 5. Validasi konflik Jumat/Dzuhur
    this.validatePrayerConflict(prayer, category, existing);

    // 6. Upsert untuk wajib
    if (category === PrayerCategory.WAJIB) {
      const existingPrayer = existing.find((p) => p.prayer === prayer);

      const updateData = {
        performed: true,
        performedAt,
        isQadha: is_qadha,
        method,
        place,
        notes: notes ?? null,
      };

      if (existingPrayer) {
        const updated = await this.prayerLogRepository.update(existingPrayer.id, updateData);

        return { prayer_log: toPrayerLogEntity(updated) };
      }
    }

    // 7. Create baru
    const created = await this.prayerLogRepository.create({
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
    });

    return { prayer_log: toPrayerLogEntity(created) };
  }

  // =========================
  // PRIVATE HELPERS
  // =========================

  private resolveCategory(prayer: PrayerType, jakartaDate: Date): PrayerCategory {
    const wajibPrayers: PrayerType[] = [
      PrayerType.SUBUH,
      PrayerType.ASHAR,
      PrayerType.MAGHRIB,
      PrayerType.ISYA,
    ];

    const isFriday = jakartaDate.getDay() === 5;

    if (prayer === PrayerType.JUMAT) {
      return isFriday ? PrayerCategory.WAJIB : PrayerCategory.SUNNAH;
    }

    if (prayer === PrayerType.DZUHUR) {
      return isFriday ? PrayerCategory.SUNNAH : PrayerCategory.WAJIB;
    }

    return wajibPrayers.includes(prayer) ? PrayerCategory.WAJIB : PrayerCategory.SUNNAH;
  }

  private validatePrayerConflict(
    prayer: PrayerType,
    category: PrayerCategory,
    existing: PrayerLog[],
  ) {
    if (category !== PrayerCategory.WAJIB) return;

    if (prayer === PrayerType.JUMAT && existing.some((p) => p.prayer === PrayerType.DZUHUR)) {
      throw new BadRequestError("Tidak bisa mencatat Jumat jika sudah ada Dzuhur", {
        prayer: "Konflik Jumat dan Dzuhur",
      });
    }

    if (prayer === PrayerType.DZUHUR && existing.some((p) => p.prayer === PrayerType.JUMAT)) {
      throw new BadRequestError("Tidak bisa mencatat Dzuhur jika sudah ada Jumat", {
        prayer: "Konflik Dzuhur dan Jumat",
      });
    }
  }
}
