import type { ReminderHookStatus } from "../../generated/prisma/client.js";

export interface INotificationHook {
  id: string;
  user_id: string;
  event_id: string;
  status: ReminderHookStatus;
  headers_json: unknown;
  payload_json: unknown;
  error_message: string | null;
  processed_at: Date | null;
  created_at: Date;
  updated_at: Date;
}
