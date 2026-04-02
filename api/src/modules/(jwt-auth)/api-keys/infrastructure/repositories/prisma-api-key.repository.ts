import { prisma } from "../../../../../config/index.js";
import { Prisma, type ApiKey } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { GetApiKeysQuery } from "../../application/dtos/api-key.dto.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";

export class PrismaApiKeyRepository implements ApiKeyRepository {
  async create(
    userId: string,
    data: { name: string; keyPreview: string; keyFull: string },
  ): Promise<ApiKey> {
    return prisma.apiKey.create({
      data: {
        userId,
        name: data.name,
        keyPreview: data.keyPreview,
        keyFull: data.keyFull,
      },
    });
  }

  async findById(userId: string, id: string): Promise<ApiKey | null> {
    const apiKey = await prisma.apiKey.findUnique({
      where: { id },
    });

    if (!apiKey || apiKey.userId !== userId || apiKey.deletedAt !== null) return null;

    return apiKey;
  }

  async update(id: string, data: Partial<ApiKey>): Promise<ApiKey> {
    return prisma.apiKey.update({
      where: { id },
      data,
    });
  }

  async softDelete(id: string): Promise<ApiKey> {
    return prisma.apiKey.update({
      where: { id },
      data: {
        deletedAt: new Date(),
      },
    });
  }

  async findAll(
    userId: string,
    filter: GetApiKeysQuery,
    pagination: PaginationType,
  ): Promise<{ apiKeys: ApiKey[]; total: number }> {
    const { skip, take } = pagination;
    const normalizedSearch = filter.search?.trim();

    const where: Prisma.ApiKeyWhereInput = {
      userId,
      deletedAt: null,
      ...(normalizedSearch
        ? {
            name: { contains: normalizedSearch, mode: "insensitive" },
          }
        : {}),
    };

    const [apiKeys, total] = await Promise.all([
      prisma.apiKey.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: "desc" },
      }),
      prisma.apiKey.count({ where }),
    ]);

    return { apiKeys, total };
  }
}
