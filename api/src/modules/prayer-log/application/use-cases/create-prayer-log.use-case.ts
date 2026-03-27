import { toZonedTime } from "date-fns-tz";
import {
  PrayerCategory,
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../lib/generated/prisma/enums.js";
import type { CreatePrayerLogRequest, CreatePrayerLogResponse } from "../dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";

export class CreatePrayerLogUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(userId: string, data: CreatePrayerLogRequest): Promise<CreatePrayerLogResponse> {
    const { prayer, performed_at, local_date, is_qadha = false, notes } = data;

    const method =
      data.method ?? (prayer === PrayerType.JUMAT ? PrayerMethod.JAMAAH : PrayerMethod.SENDIRI);
    const place =
      data.place ?? (prayer === PrayerType.JUMAT ? PrayerPlace.MASJID : PrayerPlace.RUMAH);

    const _ref = local_date ?? performed_at ?? new Date();
    const jakartaDate = toZonedTime(_ref, "Asia/Jakarta");
    const date = new Date(
      Date.UTC(jakartaDate.getFullYear(), jakartaDate.getMonth(), jakartaDate.getDate()),
    );

    const performedAt: Date = performed_at ? new Date(performed_at) : new Date();

    const wajibPrayers: PrayerType[] = [
      PrayerType.SUBUH,
      PrayerType.ASHAR,
      PrayerType.MAGHRIB,
      PrayerType.ISYA,
    ];

    const isFriday = jakartaDate.getDay() === 5;
    let category: PrayerCategory;
    if (prayer === PrayerType.JUMAT) {
      category = isFriday ? PrayerCategory.WAJIB : PrayerCategory.SUNNAH;
    } else if (prayer === PrayerType.DZUHUR) {
      category = isFriday ? PrayerCategory.SUNNAH : PrayerCategory.WAJIB;
    } else {
      category = wajibPrayers.includes(prayer) ? PrayerCategory.WAJIB : PrayerCategory.SUNNAH;
    }

    // 1. Ambil data eksisting pada HARI KALENDER yang sama
    const existing = await this.prayerLogRepository.findByUserDateAndPrayers(userId, date, [
      prayer,
      PrayerType.DZUHUR,
      PrayerType.JUMAT,
    ]);

    // 2. Logika Eksklusivitas Jumat/Dzuhur
    if (category === PrayerCategory.WAJIB || prayer === PrayerType.JUMAT) {
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
      };

      // 3. Update jika sudah ada (Upsert Logic)
      if (existingPrayer) {
        const updated = await this.prayerLogRepository.update(existingPrayer.id, baseUpdateData);
        return { prayer_log: updated };
      }
    }

    // 4. Create New (Untuk Wajib baru atau Sunnah)
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

    return { prayer_log: created };
  }
}
