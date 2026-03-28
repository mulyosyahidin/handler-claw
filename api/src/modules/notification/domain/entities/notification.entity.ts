import type { NotificationStatus } from "../../../../lib/generated/prisma/client.js";

export type INotification = {
  id: string;
  notification_webhook_id: string;
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
