import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

// ─── CREATE SCHEMA ─────────────────────────────────────────────────────────

export const createWhatsappLogSchema = z
  .object({
    // Header Info
    quick: z.boolean().default(false).openapi({ description: "Is quick reply" }),
    device: z.string().max(30).openapi({ example: "6282281666584" }),
    mode: z.string().max(10).openapi({ example: "lid" }),

    // Sender Info
    sender: z.string().max(50).openapi({ example: "6281178714117" }),
    senderlid: z
      .string()
      .max(60)
      .optional()
      .or(z.literal(""))
      .openapi({ example: "24104027574456@lid" }),
    pengirim: z.string().max(50).optional().openapi({ description: "Alias for sender" }),
    name: z
      .string()
      .max(100)
      .optional()
      .or(z.literal(""))
      .openapi({ example: "Martin Mulyo Syahidin" }),

    // Group & Member Info
    isgroup: z.boolean().default(false),
    member: z.string().max(50).optional().or(z.literal("")),
    memberlid: z.string().max(60).optional().or(z.literal("")),

    // Message Content
    message: z.string().optional().or(z.literal("")).openapi({ example: "Halo gaes" }),
    pesan: z.string().optional().or(z.literal("")), // Payload has both 'message' and 'pesan'
    text: z.string().max(100).optional().openapi({ example: "non-button message" }),
    type: z.string().max(20).openapi({ example: "text" }),
    isforwarded: z.boolean().default(false),
    inboxid: z.number().int().default(0),

    // Media & Location (Handling Empty Strings)
    extension: z.string().max(20).optional().or(z.literal("")),
    filename: z.string().max(255).optional().or(z.literal("")),
    location: z.string().max(255).optional().or(z.literal("")),

    // URL Fix: Menggunakan preprocess agar "" menjadi undefined atau tetap valid
    url: z
      .preprocess((val) => (val === "" ? undefined : val), z.string().url().max(500).optional())
      .openapi({ description: "Media or external URL" }),

    // Polls & Choices
    pollname: z.string().max(255).optional().or(z.literal("")),
    choices: z.array(z.any()).default([]),

    // Timestamp
    timestamp: z.coerce.bigint().openapi({
      example: 1773466456,
      description: "Original WA epoch timestamp",
    }),
  })
  .openapi("CreateWhatsappLog");

// ─── QUERY SCHEMA (cursor-based pagination) ─────────────────────────────────

export const getWhatsappLogsQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1, "Halaman minimal adalah 1").optional().default(1).openapi({
      description: "Nomor halaman (1-based), default: 1",
      example: 1,
    }),
    per_page: z.coerce
      .number()
      .int()
      .min(1, "Jumlah data minimal adalah 1")
      .max(200, "Maksimal data per halaman adalah 200")
      .optional()
      .default(10)
      .openapi({
        description: "Jumlah data per halaman (max 200), default: 10",
        example: 10,
      }),
    search: z.string().optional().openapi({
      description: "Search in senderName, sender, senderLid, and messageText",
      example: "martin",
    }),
    is_group: z
      .preprocess((val) => {
        if (typeof val === "string") {
          if (val === "true") return true;
          if (val === "false") return false;
        }
        return val;
      }, z.boolean().optional())
      .openapi({
        description: "Filter by group or personal logs",
        example: true,
      }),
  })
  .openapi("GetWhatsappLogsQuery");

const dateTypeEnum = z.enum([
  "today",
  "this_week",
  "this_month",
  "this_year",
  "7_days",
  "30_days",
  "1_year",
  "all",
  "custom",
]);

const dateRangeShape = {
  date_type: dateTypeEnum.default("all"),
  start: z
    .string()
    .optional()
    .refine((val) => !val || /^\d{4}-\d{2}-\d{2}$/.test(val), {
      message: "Format harus YYYY-MM-DD",
    }),
  end: z
    .string()
    .optional()
    .refine((val) => !val || /^\d{4}-\d{2}-\d{2}$/.test(val), {
      message: "Format harus YYYY-MM-DD",
    }),
};

const dateRangeSuperRefine = (
  data: { date_type: string; start?: string | undefined; end?: string | undefined },
  ctx: z.RefinementCtx,
) => {
  if (data.date_type === "custom") {
    if (!data.start) {
      ctx.addIssue({
        code: "custom",
        message: "start date is required when date_type is 'custom'",
        path: ["start"],
      });
    }
    if (!data.end) {
      ctx.addIssue({
        code: "custom",
        message: "end date is required when date_type is 'custom'",
        path: ["end"],
      });
    }
  }
};

export const getWhatsappLogsSummaryQuerySchema = z
  .object(dateRangeShape)
  .superRefine(dateRangeSuperRefine)
  .openapi("GetWhatsappLogsSummaryQuery");

export type CreateWhatsappLogSchemaValues = z.infer<typeof createWhatsappLogSchema>;
export type GetWhatsappLogsQuerySchemaValues = z.infer<typeof getWhatsappLogsQuerySchema>;
export type GetWhatsappLogsSummaryQuerySchemaValues = z.infer<
  typeof getWhatsappLogsSummaryQuerySchema
>;
