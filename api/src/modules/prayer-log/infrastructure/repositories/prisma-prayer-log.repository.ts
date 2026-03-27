import { prisma } from "../../../../config/index.js";
import { Prisma, type PrayerType } from "../../../../lib/generated/prisma/client.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import type { PrayerLog } from "../../domain/entities/prayer-log.entity.js";
import { toPrayerLogEntity } from "../mappers/prayer-log.mapper.js";
import type {
  FindAllPrayerLogData,
  PrayerLogRepositoryFilter,
} from "../../application/dtos/prayer-log.dto.js";

export class PrismaPrayerLogRepository implements PrayerLogRepository {
  async create(data: Prisma.PrayerLogUncheckedCreateInput): Promise<PrayerLog> {
    const log = await prisma.prayerLog.create({ data });

    return toPrayerLogEntity(log);
  }

  async update(id: string, data: Prisma.PrayerLogUncheckedUpdateInput): Promise<PrayerLog> {
    const log = await prisma.prayerLog.update({ where: { id }, data });

    return toPrayerLogEntity(log);
  }

  async findMany(
    userId: string,
    filter: PrayerLogRepositoryFilter,
    take?: number,
    skip?: number,
  ): Promise<FindAllPrayerLogData> {
    const where: Prisma.PrayerLogWhereInput = { userId };
    if (filter.date) where.date = filter.date;
    if (filter.performed !== undefined) where.performed = filter.performed;
    if (filter.prayer) where.prayer = filter.prayer;

    const [total, logs] = await Promise.all([
      prisma.prayerLog.count({ where }),
      prisma.prayerLog.findMany({
        where,
        orderBy: { date: "desc" },
        ...(take !== undefined ? { take } : {}),
        ...(skip !== undefined ? { skip } : {}),
      }),
    ]);

    return {
      logs: logs.map(toPrayerLogEntity),
      total,
    };
  }

  async findManySummarized(
    userId: string,
    filter: PrayerLogRepositoryFilter,
  ): Promise<PrayerLog[]> {
    const where: Prisma.PrayerLogWhereInput = { userId };
    if (filter.date) where.date = filter.date;
    if (filter.performed !== undefined) where.performed = filter.performed;
    if (filter.prayer) where.prayer = filter.prayer;

    const logs = await prisma.prayerLog.findMany({
      where,
      orderBy: { date: "desc" },
    });

    return logs.map(toPrayerLogEntity);
  }

  async findById(id: string): Promise<PrayerLog | null> {
    const log = await prisma.prayerLog.findUnique({ where: { id } });

    return log ? toPrayerLogEntity(log) : null;
  }

  async findByUserDateAndPrayers(
    userId: string,
    date: Date,
    prayers: PrayerType[],
  ): Promise<PrayerLog[]> {
    const logs = await prisma.prayerLog.findMany({
      where: {
        userId,
        date,
        prayer: { in: prayers },
      },
    });

    return logs.map(toPrayerLogEntity);
  }

  async delete(id: string): Promise<void> {
    await prisma.prayerLog.delete({ where: { id } });
  }

  async countByUserId(userId: string, filter: PrayerLogRepositoryFilter): Promise<number> {
    const where: Prisma.PrayerLogWhereInput = { userId };
    if (filter.date) where.date = filter.date;
    if (filter.performed !== undefined) where.performed = filter.performed;
    if (filter.prayer) where.prayer = filter.prayer;

    return await prisma.prayerLog.count({ where });
  }

  async getSummary(userId: string, filter: PrayerLogRepositoryFilter): Promise<any> {
    const where: Prisma.PrayerLogWhereInput = { userId };
    if (filter.date) where.date = filter.date;
    if (filter.performed !== undefined) where.performed = filter.performed;
    if (filter.prayer) where.prayer = filter.prayer;

    return await prisma.prayerLog.groupBy({
      by: ["prayer", "category", "performed", "method", "place"],
      where,
      _count: true,
    });
  }
}
