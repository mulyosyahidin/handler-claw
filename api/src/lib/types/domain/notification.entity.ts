import type { NotificationStatus, ReminderHookStatus } from "../../generated/prisma/client.js";

export interface IReminderHook {
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

export interface INotification {
  id: string;
  reminder_hook_id: string;
  user_id: string;
  user_device_id: string;
  title: string;
  body: string;
  data: unknown;
  triggered_at: Date | null;
  status: NotificationStatus;
  fcm_message_id: string | null;
  sent_at: Date | null;
  failed_at: Date | null;
  retry_count: number;
  error_message: string | null;
  created_at: Date;
  updated_at: Date;
}
