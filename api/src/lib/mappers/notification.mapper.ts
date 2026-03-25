import type { ReminderHook } from "../generated/prisma/client.js";
import type { INotificationHook } from "../types/domain/index.js";

/**
 * Maps ReminderHook PRISMA model to the IReminderHook domain entity (Notification).
 * Note: Even though the endpoint is renamed to /notifications,
 * we still use the ReminderHook model for the incoming event data.
 */
export function toNotificationEntity(p: ReminderHook): INotificationHook {
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
