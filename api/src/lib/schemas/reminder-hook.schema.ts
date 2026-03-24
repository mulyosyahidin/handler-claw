import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createReminderHookSchema = z
  .object({
    event_id: z.string().min(1, "event_id tidak boleh kosong"),
    type: z.string().min(1, "type tidak boleh kosong"),
    title: z.string().min(1, "title tidak boleh kosong"),
    message: z.string().min(1, "message tidak boleh kosong"),
    meta: z.record(z.string(), z.any()).optional(),
    link_to: z.string().optional(),
  })
  .openapi("CreateReminderHook");

export const getReminderHooksQuerySchema = z
  .object({
    page: z.coerce.number().int().positive().default(1).openapi({
      description: "Nomor halaman (1-based), default: 1",
      example: 1,
    }),
    per_page: z.coerce.number().int().min(1).max(200).default(10).openapi({
      description: "Jumlah data per halaman (max 200), default: 10",
      example: 10,
    }),
  })
  .openapi("GetReminderHooksQuery");

export type createReminderHookInput = z.infer<typeof createReminderHookSchema>;
export type GetReminderHooksQuery = z.infer<typeof getReminderHooksQuerySchema>;
