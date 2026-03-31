import { prisma } from "../../../../../config/index.js";
import {
  Prisma,
  type Account,
  type BalanceSnapshot,
  type AccountType,
} from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { CreateAccountData, GetAccountsQuery } from "../../application/dtos/account.dto.js";
import type {
  AccountRepository,
  UpdateAccountData,
} from "../../domain/repositories/account.repository.interface.js";

export class PrismaAccountRepository implements AccountRepository {
  async create(
    userId: string,
    data: CreateAccountData,
  ): Promise<Account & { accountType: AccountType; balances: BalanceSnapshot[] }> {
    return await prisma.account.create({
      data: {
        userId,
        name: data.name,
        accountTypeId: data.account_type_id,
      },
      include: {
        accountType: true,
        balances: {
          where: {
            deletedAt: null,
          },
          orderBy: {
            date: "desc",
          },
          take: 1,
        },
      },
    });
  }

  async findById(
    userId: string,
    id: string,
  ): Promise<(Account & { accountType: AccountType; balances: BalanceSnapshot[] }) | null> {
    const account = await prisma.account.findUnique({
      where: { id },
      include: {
        accountType: true,
        balances: {
          where: {
            deletedAt: null,
          },
          orderBy: {
            date: "desc",
          },
          take: 1,
        },
      },
    });

    if (!account || account.userId !== userId || account.deletedAt !== null) return null;

    return account;
  }

  async findByNameAndType(
    userId: string,
    name: string,
    accountTypeId: string,
  ): Promise<Account | null> {
    return prisma.account.findFirst({
      where: {
        userId,
        name,
        accountTypeId,
        deletedAt: null,
      },
    });
  }

  async update(
    id: string,
    data: UpdateAccountData,
  ): Promise<Account & { accountType: AccountType; balances: BalanceSnapshot[] }> {
    const updateData: any = {};
    if (data.name !== undefined) updateData.name = data.name;
    if (data.account_type_id !== undefined) updateData.accountTypeId = data.account_type_id;

    return await prisma.account.update({
      where: { id },
      data: updateData,
      include: {
        accountType: true,
        balances: {
          where: {
            deletedAt: null,
          },
          orderBy: {
            date: "desc",
          },
          take: 1,
        },
      },
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
  ): Promise<{
    accounts: (Account & { accountType: AccountType; balances: BalanceSnapshot[] })[];
    total: number;
  }> {
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
        include: {
          accountType: true,
          balances: {
            where: {
              deletedAt: null,
            },
            orderBy: {
              date: "desc",
            },
            take: 1,
          },
        },
      }),
      prisma.account.count({ where }),
    ]);

    return { accounts, total };
  }
}
