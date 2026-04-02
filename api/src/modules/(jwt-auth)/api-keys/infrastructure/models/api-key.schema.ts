import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createApiKeySchema = z
  .object({
    name: z.string().min(1, "Nama API Key tidak boleh kosong"),
  })
  .openapi("CreateApiKey");

export const updateApiKeySchema = z
  .object({
    name: z.string().min(1, "Nama API Key tidak boleh kosong"),
  })
  .openapi("UpdateApiKey");

export const getApiKeysQuerySchema = z
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
      description: "Cari berdasarkan nama API Key",
      example: "Production",
    }),
  })
  .openapi("GetApiKeysQuery");

export const apiKeyParamsSchema = z
  .object({
    id: z.string().uuid().openapi({
      description: "UUID dari API Key",
      example: "550e8400-e29b-41d4-a716-446655440000",
    }),
  })
  .openapi("ApiKeyParams");

export type CreateApiKeySchemaValues = z.infer<typeof createApiKeySchema>;
export type GetApiKeysQuerySchemaValues = z.infer<typeof getApiKeysQuerySchema>;
export type ApiKeyParamsSchemaValues = z.infer<typeof apiKeyParamsSchema>;
