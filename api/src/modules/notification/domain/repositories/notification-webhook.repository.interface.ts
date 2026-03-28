import type { NotificationWebhook } from "../../../../lib/generated/prisma/client.js";
import type {
  CreateNotificationWebhookData,
  UpdateNotificationWebhookData,
} from "../../application/dtos/notification-webhook.dto.js";

export interface NotificationWebhookRepository {
  create(userId: string, data: CreateNotificationWebhookData): Promise<NotificationWebhook>;
  update(id: string, data: UpdateNotificationWebhookData): Promise<NotificationWebhook>;
}
