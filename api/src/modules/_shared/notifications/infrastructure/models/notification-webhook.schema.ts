import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createNotificationWebhookSchema = z
  .object({
    title: z.string().min(1, "title tidak boleh kosong"),
    message: z.string().min(1, "message tidak boleh kosong"),
    meta: z.record(z.string(), z.any()).optional(),
  })
  .openapi("CreateNotification");

export type CreateNotificationWebhookSchemaValues = z.infer<typeof createNotificationWebhookSchema>;
