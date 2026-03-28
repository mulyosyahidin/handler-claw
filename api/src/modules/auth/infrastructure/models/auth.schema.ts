import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const loginSchema = z
  .object({
    email: z.email("Invalid email format"),
    password: z.string().min(1, "Password is required"),
  })
  .openapi("Login");

export const refreshTokenSchema = z
  .object({
    refresh_token: z.string().min(1, "Refresh token is required"),
  })
  .openapi("RefreshToken");

export const updateProfileSchema = z
  .object({
    name: z.string().min(1, "Nama wajib diisi").min(8, "Nama minimal 8 karakter"),
    email: z.email("Format email tidak valid"),
  })
  .openapi("UpdateProfile");

export const updatePasswordSchema = z
  .object({
    current_password: z.string().min(1, "Password saat ini wajib diisi"),
    new_password: z.string().min(8, "Password baru minimal 8 karakter"),
    confirm_new_password: z.string().min(8, "Konfirmasi password baru minimal 8 karakter"),
  })
  .refine((data) => data.new_password === data.confirm_new_password, {
    message: "Konfirmasi password baru tidak cocok",
    path: ["confirm_new_password"],
  })
  .openapi("UpdatePassword");

export type LoginSchemaValues = z.infer<typeof loginSchema>;
export type RefreshTokenSchemaValues = z.infer<typeof refreshTokenSchema>;
export type UpdateProfileSchemaValues = z.infer<typeof updateProfileSchema>;
export type UpdatePasswordSchemaValues = z.infer<typeof updatePasswordSchema>;
