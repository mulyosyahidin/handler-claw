import { prisma } from "../../../../../config/index.js";
import { Prisma, type AccountType } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateAccountTypeData,
  GetAccountTypesQuery,
} from "../../application/dtos/account-type.dto.js";
import type {
  AccountTypeRepository,
  UpdateAccountTypeData,
} from "../../domain/repositories/account-type.repository.interface.js";

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
  ): Promise<{ accountTypes: AccountType[]; total: number }> {
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

    const [accountTypes, total] = await Promise.all([
      prisma.accountType.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: "desc" },
      }),
      prisma.accountType.count({ where }),
    ]);

    return { accountTypes, total };
  }
}
