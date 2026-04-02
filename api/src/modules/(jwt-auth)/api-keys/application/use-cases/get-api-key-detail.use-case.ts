import { NotFoundError } from "../../../../../lib/errors/not-found.error.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from "../../infrastructure/mappers/api-key.mapper.js";
import type { GetApiKeyDetailResponse } from "../dtos/api-key.dto.js";

export class GetApiKeyDetailUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, id: string): Promise<GetApiKeyDetailResponse> {
    const apiKey = await this.apiKeyRepository.findById(userId, id);

    if (!apiKey) {
      throw new NotFoundError("API Key not found");
    }

    return {
      api_key: toApiKeyEntity(apiKey),
    };
  }
}
