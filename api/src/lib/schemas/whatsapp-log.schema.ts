import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

const whatsappDateTypeEnum = z.enum([
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
  date_type: whatsappDateTypeEnum.default("all"),
  start: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Format harus YYYY-MM-DD")
    .optional(),
  end: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, "Format harus YYYY-MM-DD")
    .optional(),
};

const dateRangeSuperRefine = (
  data: { date_type: string; start?: string | undefined; end?: string | undefined },
  ctx: z.RefinementCtx,
) => {
  if (data.date_type === "custom") {
    if (!data.start) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "start date is required when date_type is 'custom'",
        path: ["start"],
      });
    }
    if (!data.end) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "end date is required when date_type is 'custom'",
        path: ["end"],
      });
    }
  }
};

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
    cursor: z.coerce.number().int().positive().optional().openapi({
      description: "ID of the last item from the previous page",
      example: 100,
    }),
    take: z.coerce.number().int().min(1).max(200).default(10).openapi({
      description: "Number of items to return (max 200)",
      example: 50,
    }),
    search: z.string().optional().openapi({
      description: "Search in senderName, sender, senderLid, and messageText",
      example: "martin",
    }),
    ...dateRangeShape,
  })
  .superRefine(dateRangeSuperRefine)
  .openapi("GetWhatsappLogsQuery");

// ─── SUMMARY QUERY SCHEMA ──────────────────────────────────────────────────

export const getWhatsappLogsSummaryQuerySchema = z
  .object(dateRangeShape)
  .superRefine(dateRangeSuperRefine)
  .openapi("GetWhatsappLogsSummaryQuery");

export type CreateWhatsappLogInput = z.infer<typeof createWhatsappLogSchema>;
export type GetWhatsappLogsQuery = z.infer<typeof getWhatsappLogsQuerySchema>;
export type GetWhatsappLogsSummaryQuery = z.infer<typeof getWhatsappLogsSummaryQuerySchema>;
