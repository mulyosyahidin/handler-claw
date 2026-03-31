import { prisma } from "../../../../../config/index.js";
import { Prisma, type AccountType } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateAccountTypeData,
  GetAccountTypesQuery,
  UpdateAccountTypeData,
  AccountTypeWithMetrics,
  FindAllAccountTypesResult,
} from "../../application/dtos/account-type.dto.js";
import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";

export class PrismaAccountTypeRepository implements AccountTypeRepository {
  async create(userId: string, data: CreateAccountTypeData): Promise<AccountType> {
    return await prisma.accountType.create({
      data: {
        userId,
        name: data.name,
        category: data.category as any,
      },
    });
  }

  async findById(userId: string, id: string): Promise<AccountType | null> {
    const accountType = await prisma.accountType.findUnique({
      where: { id },
    });

    if (!accountType || accountType.userId !== userId || accountType.deletedAt !== null)
      return null;

    return accountType;
  }

  async findByName(userId: string, name: string): Promise<AccountType | null> {
    return prisma.accountType.findFirst({
      where: {
        userId,
        name,
        deletedAt: null,
      },
    });
  }

  async update(id: string, data: UpdateAccountTypeData): Promise<AccountType> {
    return await prisma.accountType.update({
      where: { id },
      data: data as any,
    });
  }

  async softDelete(id: string): Promise<AccountType> {
    return prisma.accountType.update({
      where: { id },
      data: {
        deletedAt: new Date(),
      },
    });
  }

  async findAll(
    userId: string,
    filter: GetAccountTypesQuery,
    pagination: PaginationType,
  ): Promise<FindAllAccountTypesResult> {
    const { skip, take } = pagination;
    const normalizedSearch = filter.search?.trim();

    const where: Prisma.AccountTypeWhereInput = {
      userId,
      deletedAt: null,
      ...(normalizedSearch
        ? {
            name: { contains: normalizedSearch, mode: "insensitive" },
          }
        : {}),
    };

    const [accountTypes, total, allAccountTypes] = await Promise.all([
      prisma.accountType.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: "desc" },
        include: {
          accounts: {
            where: { deletedAt: null },
            include: {
              balances: {
                where: { deletedAt: null },
                orderBy: { date: "desc" },
                take: 1,
              },
            },
          },
          _count: {
            select: {
              accounts: {
                where: { deletedAt: null },
              },
            },
          },
        },
      }),
      prisma.accountType.count({ where }),
      prisma.accountType.findMany({
        where: { userId, deletedAt: null },
        include: {
          accounts: {
            where: { deletedAt: null },
            include: {
              balances: {
                where: { deletedAt: null },
                orderBy: { date: "desc" },
                take: 1,
              },
            },
          },
        },
      }),
    ]);

    // Calculate categories summary from all account types
    const categoriesMap = new Map<string, { total_account_types: number; total_amount: number }>();

    allAccountTypes.forEach((at) => {
      const category = at.category;
      const stats = categoriesMap.get(category) || { total_account_types: 0, total_amount: 0 };
      stats.total_account_types += 1;

      at.accounts.forEach((acc) => {
        const latestBalance = acc.balances[0];
        if (latestBalance) {
          stats.total_amount += Number(latestBalance.amount);
        }
      });

      categoriesMap.set(category, stats);
    });

    const categories = Array.from(categoriesMap.entries()).map(([name, stats]) => ({
      name,
      ...stats,
    }));

    const mappedAccountTypes: AccountTypeWithMetrics[] = accountTypes.map((at) => {
      let currentTotalAmount = 0;
      const accountsList = at.accounts.map((acc) => {
        const latestBalance = acc.balances[0];
        const currentAmount = latestBalance ? Number(latestBalance.amount) : 0;
        currentTotalAmount += currentAmount;

        return {
          id: acc.id,
          name: acc.name,
          category: at.category,
          current_amount: currentAmount,
        };
      });

      const { accounts, _count, ...baseAccountType } = at;

      return {
        ...baseAccountType,
        current_total_amount: currentTotalAmount,
        account_count: _count?.accounts ?? 0,
        accounts: accountsList,
      };
    });

    return { accountTypes: mappedAccountTypes, total, categories };
  }
}
