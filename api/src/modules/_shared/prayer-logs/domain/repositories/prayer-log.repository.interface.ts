import type { PrayerLog, PrayerType } from "../../../../../lib/generated/prisma/client.js";
import type {
  CreatePrayerLogData,
  PrayerLogRepositoryFilter,
  UpdatePrayerLogData,
} from "../../application/dtos/prayer-log.dto.js";

export interface PrayerLogRepository {
  create(data: CreatePrayerLogData): Promise<PrayerLog>;
  findAll(
    userId: string,
    filter: PrayerLogRepositoryFilter,
    pagination: { skip: number; take: number },
  ): Promise<{ logs: PrayerLog[]; total: number }>;
  update(id: string, data: UpdatePrayerLogData): Promise<PrayerLog>;
  findByUserDateAndPrayers(userId: string, date: Date, prayers: PrayerType[]): Promise<PrayerLog[]>;
  findSummary(
    userId: string,
    filter: PrayerLogRepositoryFilter,
  ): Promise<
    {
      date: string;
      prayer: string;
      category: string;
      method: string;
      is_qadha: boolean;
      count: number;
    }[]
  >;
}
