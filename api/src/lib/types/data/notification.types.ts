import type { Prisma } from "../../generated/prisma/client.js";

export interface CreateNotificationPayload {
  reminder_hook_id: string;
  user_id: string;
  user_device_id: string;

  title: string;
  body: string;

  data?: Prisma.InputJsonValue | Prisma.NullableJsonNullValueInput | undefined;
}
