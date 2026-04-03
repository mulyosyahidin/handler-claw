import type { Prisma } from "../../../../../lib/generated/prisma/client.js";

export type IWebhookLog = {
  id: string;
  user_id: string;
  device_id: string;
  event: string;
  payload: Prisma.JsonValue;
  created_at: Date;
  updated_at: Date;
};
