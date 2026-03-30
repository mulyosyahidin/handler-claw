import { NotFoundError } from "../../../../lib/errors/not-found.error.js";
import { ApiKeyStatus } from "../../../../lib/generated/prisma/enums.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from '../../infrastructure/mappers/api-key.mapper.js';
import type { RevokeApiKeyResponse } from '../dtos/api-key.dto.js';

export class RevokeApiKeyUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, id: string): Promise<RevokeApiKeyResponse> {
    const apiKey = await this.apiKeyRepository.findById(userId, id);

    if (!apiKey) {
      throw new NotFoundError("API Key not found");
    }

    const result = await this.apiKeyRepository.update(id, {
      status: ApiKeyStatus.REVOKED,
    });

    return {
      api_key: toApiKeyEntity(result)
    };
  }
}
