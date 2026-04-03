import { BadRequestError } from "../../../../../lib/errors/bad-request.error.js";
import type { CreateWebhookLogData, CreateWebhookLogResponse } from "../dtos/whatsapp-hook.dto.js";
import type { WhatsappHookRepository } from "../../domain/repositories/whatsapp-hook.repository.js";
import { toWebhookLogEntity } from "../../infrastructure/mappers/whatsapp-hook.mapper.js";

export class CreateWebhookLogUseCase {
  constructor(private whatsappHookRepository: WhatsappHookRepository) {}

  async execute(
    userId: string | null,
    data: CreateWebhookLogData,
  ): Promise<CreateWebhookLogResponse> {
    if (!userId) {
      throw new BadRequestError("User ID is required to log webhooks");
    }

    if (data.event !== "message") {
      return {
        webhook_log: null,
      };
    }

    const created = await this.whatsappHookRepository.create(userId, data);

    return {
      webhook_log: toWebhookLogEntity(created),
    };
  }
}
