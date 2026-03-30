import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createAccountSchema = z
  .object({
    name: z.string().min(1, "Nama akun tidak boleh kosong"),
    account_type_id: z.string().uuid("ID tipe akun tidak valid"),
  })
  .openapi("CreateAccount");

export const updateAccountSchema = z
  .object({
    name: z.string().min(1, "Nama akun tidak boleh kosong").optional(),
    account_type_id: z.string().uuid("ID tipe akun tidak valid").optional(),
  })
  .openapi("UpdateAccount");

export const getAccountsQuerySchema = z
  .object({
    page: z.coerce.number().int().positive().default(1).openapi({
      description: "Nomor halaman (1-based), default: 1",
      example: 1,
    }),
    per_page: z.coerce.number().int().min(1).max(200).default(10).openapi({
      description: "Jumlah data per halaman (max 200), default: 10",
      example: 10,
    }),
    search: z.string().optional().openapi({
      description: "Cari berdasarkan nama akun",
      example: "Mandiri Utama",
    }),
  })
  .openapi("GetAccountsQuery");

export const accountParamsSchema = z
  .object({
    id: z.string().uuid().openapi({
      description: "UUID dari Akun",
      example: "550e8400-e29b-41d4-a716-446655440000",
    }),
  })
  .openapi("AccountParams");

export type CreateAccountSchemaValues = z.infer<typeof createAccountSchema>;
export type UpdateAccountSchemaValues = z.infer<typeof updateAccountSchema>;
export type GetAccountsQuerySchemaValues = z.infer<typeof getAccountsQuerySchema>;
export type AccountParamsSchemaValues = z.infer<typeof accountParamsSchema>;
