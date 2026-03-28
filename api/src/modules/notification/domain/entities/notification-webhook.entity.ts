import type { Prisma } from "../../../../lib/generated/prisma/client.js";
import type { NotificationWebhookStatus } from "../../../../lib/generated/prisma/enums.js";

export type INotificationWebhook = {
  id: string;
  user_id: string;
  status: NotificationWebhookStatus;
  content: Prisma.JsonValue;
  created_at: Date;
  updated_at: Date;
};
