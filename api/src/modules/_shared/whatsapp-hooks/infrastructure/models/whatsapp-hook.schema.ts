import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createWebhookLogSchema = z.object({
  device_id: z.string().min(1, "Device ID is required"),
  event: z.string().min(1, "Event is required"),
  payload: z.any(),
});

export const getWhatsappMessagesQuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  per_page: z.coerce.number().int().positive().default(10),
  search: z.string().optional(),
  chat_id: z.string().optional(),
  message_type: z.string().optional(), // Using string because enum is from prisma
  is_from_me: z.string().optional(),
});

export type CreateWebhookLogSchemaValues = z.infer<typeof createWebhookLogSchema>;
export type GetWhatsappMessagesQuerySchemaValues = z.infer<typeof getWhatsappMessagesQuerySchema>;
