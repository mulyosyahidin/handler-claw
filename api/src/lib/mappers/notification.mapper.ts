import type { ReminderHook } from "../generated/prisma/client.js";
import type { IReminderHook } from "../types/domain/index.js";

export function toReminderHookEntity(p: ReminderHook): IReminderHook {
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
