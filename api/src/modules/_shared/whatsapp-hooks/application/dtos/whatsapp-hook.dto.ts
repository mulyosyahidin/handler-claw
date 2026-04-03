import type { Prisma } from "../../../../../lib/generated/prisma/client.js";
import type { IWebhookLog } from "../../domain/entities/whatsapp-hook.entity.js";
import type { IWhatsappMessage } from "../../domain/entities/whatsapp-message.entity.js";

/**
 * Input Data Contracts
 */
export type CreateWebhookLogData = {
  deviceId: string;
  event: string;
  payload: Prisma.JsonValue | Prisma.InputJsonValue;
};

/**
 * Output Data Contracts
 */
export type CreateWebhookLogResponse = {
  webhook_log: IWebhookLog | null;
  message?: IWhatsappMessage | null;
};
