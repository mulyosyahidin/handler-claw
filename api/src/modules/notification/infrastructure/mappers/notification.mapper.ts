import type { Notification, ReminderHook } from "../../../../lib/generated/prisma/client.js";
import type {
  Notification as Entity,
  ReminderHook as HookEntity,
} from "../../domain/entities/notification.entity.js";

export function toReminderHookEntity(p: ReminderHook): HookEntity {
  return {
    id: p.id,
    user_id: p.userId,
    event_id: p.eventId,
    status: p.status,
    headers_json: p.headersJson,
    payload_json: p.payloadJson,
    error_message: p.errorMessage,
    processed_at: p.processedAt,
    created_at: p.createdAt,
    updated_at: p.updatedAt,
  };
}

export function toNotificationEntity(p: Notification): Entity {
  return {
    id: p.id,
    reminder_hook_id: p.reminderHookId,
    user_id: p.userId,
    user_device_id: p.userDeviceId,
    title: p.title,
    body: p.body,
    data: p.data,
    triggered_at: p.triggeredAt,
    status: p.status,
    fcm_message_id: p.fcmMessageId,
    sent_at: p.sentAt,
    failed_at: p.failedAt,
    retry_count: p.retryCount,
    error_message: p.errorMessage,
    created_at: p.createdAt,
    updated_at: p.updatedAt,
  };
}
