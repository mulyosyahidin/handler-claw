import type { WebhookLog } from "../../../../../lib/generated/prisma/client.js";
import type { IWebhookLog } from "../../domain/entities/whatsapp-hook.entity.js";

export function toWebhookLogEntity(data: WebhookLog): IWebhookLog {
  return {
    id: data.id,
    user_id: data.userId,
    device_id: data.deviceId,
    event: data.event,
    payload: data.payload,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
