import { generateApiKey, getApiKeyPreview, hashApiKey } from "../../../../../lib/api-key.js";
import { NotFoundError } from "../../../../../lib/errors/not-found.error.js";
import { ApiKeyStatus } from "../../../../../lib/generated/prisma/enums.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from "../../infrastructure/mappers/api-key.mapper.js";
import type { CreateApiKeyResponse } from "../dtos/api-key.dto.js";

export class RotateApiKeyUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, id: string): Promise<CreateApiKeyResponse> {
    const apiKey = await this.apiKeyRepository.findById(userId, id);

    if (!apiKey) {
      throw new NotFoundError("API Key not found");
    }

    const plainKey = generateApiKey();
    const hash = hashApiKey(plainKey);
    const preview = getApiKeyPreview(plainKey);

    const updated = await this.apiKeyRepository.update(id, {
      keyFull: hash,
      keyPreview: preview,
      status: ApiKeyStatus.ACTIVE, // Ensure it's active if it was revoked
    });

    return {
      api_key: {
        ...toApiKeyEntity(updated),
        plain_key: plainKey,
      },
    };
  }
}
