import { prisma } from "../../../../../config/index.js";
import { PrayerType, Prisma, type PrayerLog } from "../../../../../lib/generated/prisma/client.js";
import type {
  CreatePrayerLogData,
  PrayerLogRepositoryFilter,
  UpdatePrayerLogData,
} from "../../application/dtos/prayer-log.dto.js";
import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";

export class PrismaPrayerLogRepository implements PrayerLogRepository {
  async create(data: CreatePrayerLogData): Promise<PrayerLog> {
    return prisma.prayerLog.create({
      data: {
        userId: data.userId,
        date: data.date,
        prayer: data.prayer,
        performed: data.performed,
        category: data.category,
        ...(data.performedAt !== undefined ? { performedAt: data.performedAt } : {}),
        ...(data.method !== undefined ? { method: data.method } : {}),
        ...(data.place !== undefined ? { place: data.place } : {}),
        ...(data.isQadha !== undefined ? { isQadha: data.isQadha } : {}),
        ...(data.notes !== undefined ? { notes: data.notes } : {}),
      },
    });
  }

  async findAll(
    userId: string,
    filter: PrayerLogRepositoryFilter,
    pagination: { skip: number; take: number },
  ): Promise<{ logs: PrayerLog[]; total: number }> {
    const { skip, take } = pagination;

    const where: Prisma.PrayerLogWhereInput = {
      userId,
      ...(filter.date
        ? {
            date: {
              ...(filter.date.gte !== undefined ? { gte: filter.date.gte } : {}),
              ...(filter.date.lte !== undefined ? { lte: filter.date.lte } : {}),
              ...(filter.date.gt !== undefined ? { gt: filter.date.gt } : {}),
              ...(filter.date.lt !== undefined ? { lt: filter.date.lt } : {}),
            },
          }
        : {}),
      ...(filter.performed !== undefined ? { performed: filter.performed } : {}),
      ...(filter.prayer ? { prayer: filter.prayer } : {}),
    };

    const [total, logs] = await Promise.all([
      prisma.prayerLog.count({ where }),
      prisma.prayerLog.findMany({
        where,
        orderBy: [{ date: "desc" }, { performedAt: "desc" }],
        skip,
        take,
      }),
    ]);

    return {
      logs,
      total,
    };
  }

  async update(id: string, data: UpdatePrayerLogData): Promise<PrayerLog> {
    const log = await prisma.prayerLog.update({
      where: { id },
      data: {
        ...(data.performed !== undefined ? { performed: data.performed } : {}),
        ...(data.performedAt !== undefined ? { performedAt: data.performedAt } : {}),
        ...(data.category !== undefined ? { category: data.category } : {}),
        ...(data.method !== undefined ? { method: data.method } : {}),
        ...(data.place !== undefined ? { place: data.place } : {}),
        ...(data.isQadha !== undefined ? { isQadha: data.isQadha } : {}),
        ...(data.notes !== undefined ? { notes: data.notes } : {}),
      },
    });

    return log;
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

    return logs;
  }

  async findSummary(
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
  > {
    const conditions: string[] = [`"user_id" = $1`];
    const values: any[] = [userId];

    let idx = 2;

    if (filter.date?.gte) {
      conditions.push(`"date" >= $${idx++}`);
      values.push(filter.date.gte);
    }

    if (filter.date?.lt) {
      conditions.push(`"date" < $${idx++}`);
      values.push(filter.date.lt);
    }

    if (filter.performed !== undefined) {
      conditions.push(`"performed" = $${idx++}`);
      values.push(filter.performed);
    }

    if (filter.prayer) {
      conditions.push(`"prayer" = $${idx++}`);
      values.push(filter.prayer);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

    const result = await prisma.$queryRawUnsafe<
      {
        date: string;
        prayer: string;
        category: string;
        method: string;
        is_qadha: boolean;
        count: number;
      }[]
    >(
      `
      SELECT
        DATE("date") as date,
        prayer,
        category,
        method,
        is_qadha,
        COUNT(*) as count,
        MAX("performed_at") as last_performed_at
      FROM prayer_logs
      ${whereClause}
      GROUP BY DATE("date"), prayer, category, method, is_qadha
      ORDER BY DATE("date") DESC, last_performed_at ASC
    `,
      ...values,
    );

    return result;
  }
}
