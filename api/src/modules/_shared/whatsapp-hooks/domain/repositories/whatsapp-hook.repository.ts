import type { WebhookLog } from "../../../../../lib/generated/prisma/client.js";
import type { CreateWebhookLogData } from "../../application/dtos/whatsapp-hook.dto.js";

export interface WhatsappHookRepository {
  create(userId: string, data: CreateWebhookLogData): Promise<WebhookLog>;
}
