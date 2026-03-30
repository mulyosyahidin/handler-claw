import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";
import { AccountCategory } from "../../../../../lib/generated/prisma/enums.js";

extendZodWithOpenApi(z);

const AccountCategoryEnum = z.nativeEnum(AccountCategory);

export const createAccountTypeSchema = z
  .object({
    name: z.string().min(1, "Nama tipe akun tidak boleh kosong"),
    category: AccountCategoryEnum.openapi({
      description: "Kategori tipe akun",
    }),
  })
  .openapi("CreateAccountType");

export const updateAccountTypeSchema = z
  .object({
    name: z.string().min(1, "Nama tipe akun tidak boleh kosong").optional(),
    category: AccountCategoryEnum.optional(),
  })
  .openapi("UpdateAccountType");

export const getAccountTypesQuerySchema = z
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
      description: "Cari berdasarkan nama tipe akun",
      example: "Bank",
    }),
  })
  .openapi("GetAccountTypesQuery");

export const accountTypeParamsSchema = z
  .object({
    id: z.string().uuid().openapi({
      description: "UUID dari Tipe Akun",
      example: "550e8400-e29b-41d4-a716-446655440000",
    }),
  })
  .openapi("AccountTypeParams");

export type CreateAccountTypeSchemaValues = z.infer<typeof createAccountTypeSchema>;
export type UpdateAccountTypeSchemaValues = z.infer<typeof updateAccountTypeSchema>;
export type GetAccountTypesQuerySchemaValues = z.infer<typeof getAccountTypesQuerySchema>;
export type AccountTypeParamsSchemaValues = z.infer<typeof accountTypeParamsSchema>;
