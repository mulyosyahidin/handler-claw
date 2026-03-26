import { z } from "zod";
import { PrayerMethod, PrayerPlace, PrayerType } from "../generated/prisma/enums.js";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

// ENUMS
const prayerTypeEnum = z.enum(PrayerType, {
  error: () => ({
    message: "Invalid prayer type",
  }),
});
const prayerMethodEnum = z.enum(PrayerMethod);
const prayerPlaceEnum = z.enum(PrayerPlace);

export const logPrayerSchema = z
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
    if (data.prayer === PrayerType.JUMAT && data.is_qadha) {
      ctx.addIssue({
        code: "custom",
        message: "solat jumat tidak memiliki konsep qadha",
        path: ["is_qadha"],
      });
    }
  })
  .openapi("PrayerLog");

export type LogPrayerInput = z.infer<typeof logPrayerSchema>;

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

const dateRangeShape = {
  date_type: prayerDateTypeEnum.default("all"),
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

export const getPrayerLogsQuerySchema = z
  .object({
    page: z.coerce.number().int().min(1).default(1),
    per_page: z.coerce.number().int().min(1).max(100).default(10),
    ...dateRangeShape,
  })
  .superRefine(dateRangeSuperRefine);

export const getPrayerLogsSummaryQuerySchema = z
  .object(dateRangeShape)
  .superRefine(dateRangeSuperRefine);

export type GetPrayerLogsQuery = z.infer<typeof getPrayerLogsQuerySchema>;
export type GetPrayerLogsSummaryQuery = z.infer<typeof getPrayerLogsSummaryQuerySchema>;
