import { prisma } from "../../../../../config/index.js";
import { Prisma, type Account } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { CreateAccountData, GetAccountsQuery } from "../../application/dtos/account.dto.js";
import type {
  AccountRepository,
  UpdateAccountData,
} from "../../domain/repositories/account.repository.interface.js";

export class PrismaAccountRepository implements AccountRepository {
  async create(userId: string, data: CreateAccountData): Promise<Account> {
    return await prisma.account.create({
      data: {
        userId,
        name: data.name,
        accountTypeId: data.account_type_id,
      },
    });
  }

  async findById(userId: string, id: string): Promise<Account | null> {
    const account = await prisma.account.findUnique({
      where: { id },
    });

    if (!account || account.userId !== userId || account.deletedAt !== null) return null;

    return account;
  }

  async findByName(userId: string, name: string): Promise<Account | null> {
    return prisma.account.findFirst({
      where: {
        userId,
        name,
        deletedAt: null,
      },
    });
  }

  async update(id: string, data: UpdateAccountData): Promise<Account> {
    const updateData: any = {};
    if (data.name !== undefined) updateData.name = data.name;
    if (data.account_type_id !== undefined) updateData.accountTypeId = data.account_type_id;

    return await prisma.account.update({
      where: { id },
      data: updateData,
    });
  }

  async softDelete(id: string): Promise<Account> {
    return prisma.account.update({
      where: { id },
      data: {
        deletedAt: new Date(),
      },
    });
  }

  async findAll(
    userId: string,
    filter: GetAccountsQuery,
    pagination: PaginationType,
  ): Promise<{ accounts: Account[]; total: number }> {
    const { skip, take } = pagination;
    const normalizedSearch = filter.search?.trim();

    const where: Prisma.AccountWhereInput = {
      userId,
      deletedAt: null,
      ...(normalizedSearch
        ? {
            name: { contains: normalizedSearch, mode: "insensitive" },
          }
        : {}),
    };

    const [accounts, total] = await Promise.all([
      prisma.account.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: "desc" },
      }),
      prisma.account.count({ where }),
    ]);

    return { accounts, total };
  }
}
