import type { Prisma, PrayerType } from "../../../../lib/generated/prisma/client.js";
import type { PrayerLog } from "../entities/prayer-log.entity.js";
import type {
  PrayerLogRepositoryFilter,
  FindAllPrayerLogData,
} from "../../application/dtos/prayer-log.dto.js";

export interface PrayerLogRepository {
  create(data: Prisma.PrayerLogUncheckedCreateInput): Promise<PrayerLog>;
  update(id: string, data: Prisma.PrayerLogUncheckedUpdateInput): Promise<PrayerLog>;
  findMany(
    userId: string,
    filter: PrayerLogRepositoryFilter,
    take?: number,
    skip?: number,
  ): Promise<FindAllPrayerLogData>;
  findManySummarized(userId: string, filter: PrayerLogRepositoryFilter): Promise<PrayerLog[]>;
  findById(id: string): Promise<PrayerLog | null>;
  findByUserDateAndPrayers(userId: string, date: Date, prayers: PrayerType[]): Promise<PrayerLog[]>;
  delete(id: string): Promise<void>;
  countByUserId(userId: string, filter: PrayerLogRepositoryFilter): Promise<number>;
  getSummary(userId: string, filter: PrayerLogRepositoryFilter): Promise<any>;
}
