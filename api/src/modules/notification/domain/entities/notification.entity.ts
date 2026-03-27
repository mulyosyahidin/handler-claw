import type {
  NotificationStatus,
  ReminderHookStatus,
} from "../../../../lib/generated/prisma/client.js";

export type ReminderHook = {
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
};

export type Notification = {
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
};
