import { z } from "zod";
import {
  PrayerMethod,
  PrayerPlace,
  PrayerType,
} from "../../../../../lib/generated/prisma/enums.js";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

// ENUMS
const prayerTypeEnum = z.enum(PrayerType as any, {
  error: () => ({
    message: "Invalid prayer type",
  }),
});

const prayerMethodEnum = z.enum(PrayerMethod as any);
const prayerPlaceEnum = z.enum(PrayerPlace as any);

const prayerDateTypeEnum = z.enum([
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

const emptyToUndefined = (val: unknown) => (val === "" ? undefined : val);

export const insertLogPrayerSchema = z
  .object({
    prayer: prayerTypeEnum,
    local_date: z.coerce.date().optional(),
    performed_at: z.coerce.date().optional(),
    method: prayerMethodEnum.optional(),
    place: prayerPlaceEnum.optional(),
    is_qadha: z.coerce.boolean().default(false),
    notes: z.string().trim().min(1).max(500).optional(),
  })
  .superRefine((data, ctx) => {
    if (data.prayer === (PrayerType as any).JUMAT && data.is_qadha) {
      ctx.addIssue({
        code: "custom",
        message: "solat jumat tidak memiliki konsep qadha",
        path: ["is_qadha"],
      });
    }
  })
  .openapi("PrayerLog");

const dateRangeShape = {
  date_type: prayerDateTypeEnum.default("all"),
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

export const getPrayerLogsQuerySchema = z
  .object({
    page: z.preprocess(emptyToUndefined, z.coerce.number().int().min(1).default(1)),
    per_page: z.preprocess(emptyToUndefined, z.coerce.number().int().min(1).max(100).default(10)),
    ...dateRangeShape,
  })
  .superRefine(dateRangeSuperRefine);

export const getPrayerLogsSummaryQuerySchema = z
  .object(dateRangeShape)
  .superRefine(dateRangeSuperRefine);

export type InsertLogPrayerSchemaValues = z.infer<typeof insertLogPrayerSchema>;
export type GetPrayerLogsQuerySchemaValues = z.infer<typeof getPrayerLogsQuerySchema>;
export type GetPrayerLogsSummaryQuerySchemaValues = z.infer<typeof getPrayerLogsSummaryQuerySchema>;
