import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const createAccountSnapshotSchema = z
  .object({
    account_id: z.string().uuid("ID akun tidak valid"),
    amount: z.number().min(0, "Jumlah saldo tidak boleh negatif"),
    date: z
      .string()
      .transform((val, ctx) => {
        const d = new Date(val);
        if (isNaN(d.getTime())) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Format tanggal tidak valid. Gunakan format YYYY-MM-DD (contoh: 2026-03-31)",
          });
          return z.NEVER;
        }
        return d;
      })
      .openapi({
        type: "string",
        format: "date",
        description: "Tanggal snapshot saldo",
        example: "2026-03-31",
      }),
    note: z.string().optional().nullable().openapi({
      description: "Catatan tambahan",
      example: "Saldo awal bulan",
    }),
  })
  .openapi("CreateAccountSnapshot");

export const updateAccountSnapshotSchema = z
  .object({
    amount: z.number().min(0, "Jumlah saldo tidak boleh negatif").optional(),
    date: z
      .string()
      .transform((val, ctx) => {
        const d = new Date(val);
        if (isNaN(d.getTime())) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Format tanggal tidak valid. Gunakan format YYYY-MM-DD (contoh: 2026-03-31)",
          });
          return z.NEVER;
        }
        return d;
      })
      .optional(),
    note: z.string().optional().nullable(),
  })
  .openapi("UpdateAccountSnapshot");

export const getAccountSnapshotsQuerySchema = z
  .object({
    page: z.coerce.number().int().positive().default(1).openapi({
      description: "Nomor halaman (1-based), default: 1",
      example: 1,
    }),
    per_page: z.coerce.number().int().min(1).max(200).default(10).openapi({
      description: "Jumlah data per halaman (max 200), default: 10",
      example: 10,
    }),
    account_id: z.string().uuid().optional().openapi({
      description: "Filter berdasarkan ID akun",
    }),
    start_date: z
      .string()
      .transform((val, ctx) => {
        const d = new Date(val);
        if (isNaN(d.getTime())) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Format tanggal tidak valid. Gunakan format YYYY-MM-DD (contoh: 2026-03-31)",
          });
          return z.NEVER;
        }
        return d;
      })
      .optional()
      .openapi({
        type: "string",
        format: "date",
        description: "Filter tanggal mulai",
      }),
    end_date: z
      .string()
      .transform((val, ctx) => {
        const d = new Date(val);
        if (isNaN(d.getTime())) {
          ctx.addIssue({
            code: z.ZodIssueCode.custom,
            message: "Format tanggal tidak valid. Gunakan format YYYY-MM-DD (contoh: 2026-03-31)",
          });
          return z.NEVER;
        }
        return d;
      })
      .optional()
      .openapi({
        type: "string",
        format: "date",
        description: "Filter tanggal selesai",
      }),
  })
  .openapi("GetAccountSnapshotsQuery");

export const accountSnapshotParamsSchema = z
  .object({
    id: z.string().uuid().openapi({
      description: "UUID dari Snapshot Saldo",
      example: "550e8400-e29b-41d4-a716-446655440000",
    }),
  })
  .openapi("AccountSnapshotParams");

export type CreateAccountSnapshotSchemaValues = z.infer<typeof createAccountSnapshotSchema>;
export type UpdateAccountSnapshotSchemaValues = z.infer<typeof updateAccountSnapshotSchema>;
export type GetAccountSnapshotsQuerySchemaValues = z.infer<typeof getAccountSnapshotsQuerySchema>;
export type AccountSnapshotParamsSchemaValues = z.infer<typeof accountSnapshotParamsSchema>;
