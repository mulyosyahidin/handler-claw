import { z } from "zod";
import { PrayerMethod, PrayerPlace, PrayerType } from "../generated/prisma/enums.js";

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
  });

export type LogPrayerInput = z.infer<typeof logPrayerSchema>;
