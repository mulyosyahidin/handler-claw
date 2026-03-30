import { NotFoundError } from "../../../../lib/errors/not-found.error.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";
import { toApiKeyEntity } from "../../infrastructure/mappers/api-key.mapper.js";
import type { UpdateApiKeyResponse, UpdateApiKeyRequest } from "../dtos/api-key.dto.js";

export class UpdateApiKeyUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(
    userId: string,
    id: string,
    input: UpdateApiKeyRequest,
  ): Promise<UpdateApiKeyResponse> {
    const apiKey = await this.apiKeyRepository.findById(userId, id);

    if (!apiKey) {
      throw new NotFoundError("API Key not found");
    }

    const updated = await this.apiKeyRepository.update(id, {
      name: input.name,
    });

    return {
      api_key: toApiKeyEntity(updated),
    };
  }
}
