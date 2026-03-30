import { generateApiKey, getApiKeyPreview, hashApiKey } from "../../../../lib/api-key.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from "../../infrastructure/mappers/api-key.mapper.js";
import type { CreateApiKeyRequest, CreateApiKeyResponse } from "../dtos/api-key.dto.js";

export class CreateApiKeyUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, input: CreateApiKeyRequest): Promise<CreateApiKeyResponse> {
    const plainKey = generateApiKey();
    const hash = hashApiKey(plainKey);
    const preview = getApiKeyPreview(plainKey);

    const apiKey = await this.apiKeyRepository.create(userId, {
      name: input.name,
      keyPreview: preview,
      keyFull: hash,
    });

    return {
      api_key: {
        ...toApiKeyEntity(apiKey),
        plain_key: plainKey,
      },
    };
  }
}
