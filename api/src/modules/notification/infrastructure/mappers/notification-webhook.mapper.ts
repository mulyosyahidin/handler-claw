import type { NotificationWebhook } from "../../../../lib/generated/prisma/client.js";
import type { INotificationWebhook } from "../../domain/entities/notification-webhook.entity.js";

export function toNotificationWebhookEntity(data: NotificationWebhook): INotificationWebhook {
  return {
    id: data.id,
    user_id: data.userId,
    content: data.content,
    status: data.status,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
