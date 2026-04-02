import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { NotificationStatus } from "../../../../../lib/generated/prisma/enums.js";

extendZodWithOpenApi(z);

const NotificationStatusEnum = z.enum(NotificationStatus);

export const getNotificationsQuerySchema = z
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
    status: NotificationStatusEnum.optional().openapi({
      description: "Filter berdasarkan status",
      example: "SENT",
    }),
    search: z.string().optional().openapi({
      description: "Search in title, body",
      example: "martin",
    }),
  })
  .openapi("GetNotificationsQuery");

export const getNotificationParamsSchema = z.object({
  id: z.string().min(1, "ID tidak boleh kosong"),
});

export type GetNotificationsQuerySchemaValues = z.infer<typeof getNotificationsQuerySchema>;
export type GetNotificationParamsSchemaValues = z.infer<typeof getNotificationParamsSchema>;
