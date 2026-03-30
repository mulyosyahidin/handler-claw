import { prisma } from "../../../../../config/index.js";
import { Prisma, type BalanceSnapshot } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateAccountSnapshotData,
  GetAccountSnapshotsQuery,
} from "../../application/dtos/account-snapshot.dto.js";
import type {
  AccountSnapshotRepository,
  UpdateAccountSnapshotData,
} from "../../domain/repositories/account-snapshot.repository.interface.js";

export class PrismaAccountSnapshotRepository implements AccountSnapshotRepository {
  async create(data: CreateAccountSnapshotData): Promise<BalanceSnapshot> {
    const createData: Prisma.BalanceSnapshotUncheckedCreateInput = {
      accountId: data.account_id,
      amount: data.amount,
      date: data.date,
    };

    if (data.note !== undefined) {
      createData.note = data.note;
    }

    return await prisma.balanceSnapshot.create({
      data: createData,
    });
  }

  async findById(userId: string, id: string): Promise<BalanceSnapshot | null> {
    const snapshot = await prisma.balanceSnapshot.findUnique({
      where: { id },
      include: {
        account: true,
      },
    });

    if (!snapshot || snapshot.account.userId !== userId || snapshot.deletedAt !== null) return null;

    return snapshot;
  }

  async findByDate(accountId: string, date: Date): Promise<BalanceSnapshot | null> {
    // Normalize date to YYYY-MM-DD for comparison if needed,
    // but Prisma's @db.Date should handle it if passed correctly as Date object
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    return prisma.balanceSnapshot.findFirst({
      where: {
        accountId,
        date: startOfDay,
        deletedAt: null,
      },
    });
  }

  async update(id: string, data: UpdateAccountSnapshotData): Promise<BalanceSnapshot> {
    const updateData: any = {};
    if (data.amount !== undefined) updateData.amount = data.amount;
    if (data.date !== undefined) updateData.date = data.date;
    if (data.note !== undefined) updateData.note = data.note;

    return await prisma.balanceSnapshot.update({
      where: { id },
      data: updateData,
    });
  }

  async softDelete(id: string): Promise<BalanceSnapshot> {
    return prisma.balanceSnapshot.update({
      where: { id },
      data: {
        deletedAt: new Date(),
      },
    });
  }

  async findAll(
    userId: string,
    filter: GetAccountSnapshotsQuery,
    pagination: PaginationType,
  ): Promise<{ snapshots: BalanceSnapshot[]; total: number }> {
    const { skip, take } = pagination;

    const where: Prisma.BalanceSnapshotWhereInput = {
      account: {
        userId,
      },
      deletedAt: null,
      ...(filter.account_id ? { accountId: filter.account_id } : {}),
      ...(filter.start_date || filter.end_date
        ? {
            date: {
              ...(filter.start_date ? { gte: filter.start_date } : {}),
              ...(filter.end_date ? { lte: filter.end_date } : {}),
            },
          }
        : {}),
    };

    const [snapshots, total] = await Promise.all([
      prisma.balanceSnapshot.findMany({
        where,
        skip,
        take,
        orderBy: { date: "desc" },
      }),
      prisma.balanceSnapshot.count({ where }),
    ]);

    return { snapshots, total };
  }
}
