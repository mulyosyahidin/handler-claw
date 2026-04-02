import type { Notification } from "../../../../../lib/generated/prisma/client.js";
import type { INotification } from "../../domain/entities/notification.entity.js";

export function toNotificationEntity(data: Notification): INotification {
  return {
    id: data.id,
    notification_webhook_id: data.notificationWebhookId,
    user_id: data.userId,
    user_device_id: data.userDeviceId,
    title: data.title,
    body: data.body,
    data: data.data,
    triggered_at: data.triggeredAt,
    status: data.status,
    fcm_message_id: data.fcmMessageId,
    sent_at: data.sentAt,
    failed_at: data.failedAt,
    retry_count: data.retryCount,
    error_message: data.errorMessage,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
