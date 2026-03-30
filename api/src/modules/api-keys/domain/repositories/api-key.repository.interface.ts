import { type ApiKey } from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type { GetApiKeysQuery } from "../../application/dtos/api-key.dto.js";

export interface ApiKeyRepository {
  create(
    userId: string,
    data: { name: string; keyPreview: string; keyFull: string },
  ): Promise<ApiKey>;
  findAll(
    userId: string,
    filter: GetApiKeysQuery,
    pagination: PaginationType,
  ): Promise<{ apiKeys: ApiKey[]; total: number }>;
  findById(userId: string, id: string): Promise<ApiKey | null>;
  update(id: string, data: Partial<ApiKey>): Promise<ApiKey>;
  softDelete(id: string): Promise<ApiKey>;
}
