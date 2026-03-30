import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from "../../infrastructure/mappers/api-key.mapper.js";
import type { GetApiKeysQuery, GetApiKeysResponse } from "../dtos/api-key.dto.js";

export class GetApiKeysUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, filter: GetApiKeysQuery): Promise<GetApiKeysResponse> {
    const pagination: PaginationType = {
      skip: (filter.page - 1) * filter.per_page,
      take: filter.per_page,
    };

    const { apiKeys, total } = await this.apiKeyRepository.findAll(userId, filter, pagination);

    return {
      api_keys: apiKeys.map(toApiKeyEntity),
      meta: {
        page: filter.page,
        per_page: filter.per_page,
        total,
        total_pages: Math.ceil(total / filter.per_page),
      },
    };
  }
}
