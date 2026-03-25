import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";
import { UserDevicePlatform, UserDeviceStatus } from "../generated/prisma/enums.js";

extendZodWithOpenApi(z);

export const createUserDeviceSchema = z
  .object({
    device_id: z.string().min(1, "device_id tidak boleh kosong"),
    device_brand: z.string().optional(),
    device_model: z.string().optional(),
    os_version: z.string().optional(),
    fcm_token: z.string().min(1, "fcm_token tidak boleh kosong"),
    platform: z.nativeEnum(UserDevicePlatform).default(UserDevicePlatform.ANDROID),
  })
  .openapi("CreateUserDevice");

export const updateUserDeviceStatusSchema = z
  .object({
    device_id: z.string().min(1, "device_id tidak boleh kosong"),
    status: z.nativeEnum(UserDeviceStatus),
  })
  .openapi("UpdateUserDeviceStatus");

export const getUserDevicesQuerySchema = z
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
  .openapi("GetUserDevicesQuery");

export type CreateUserDeviceInput = z.infer<typeof createUserDeviceSchema>;
export type UpdateUserDeviceStatusInput = z.infer<typeof updateUserDeviceStatusSchema>;
export type GetUserDevicesQuery = z.infer<typeof getUserDevicesQuerySchema>;
