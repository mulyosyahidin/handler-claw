import { NotFoundError } from "../../../../lib/errors/not-found.error.js";
import type { ApiKeyRepository } from "../../domain/repositories/api-key.repository.interface.js";

export class DeleteApiKeyUseCase {
  constructor(private apiKeyRepository: ApiKeyRepository) {}

  async execute(userId: string, id: string): Promise<void> {
    const apiKey = await this.apiKeyRepository.findById(userId, id);

    if (!apiKey) {
      throw new NotFoundError("API Key not found");
    }

    await this.apiKeyRepository.softDelete(id);
  }
}
