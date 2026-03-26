import { z } from "zod";
import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";

extendZodWithOpenApi(z);

export const loginSchema = z
  .object({
    email: z.email("Invalid email format"),
    password: z.string().min(1, "Password is required"),
  })
  .openapi("Login");

export type LoginRequest = z.infer<typeof loginSchema>;

export const refreshTokenSchema = z
  .object({
    refresh_token: z.string().min(1, "Refresh token is required"),
  })
  .openapi("RefreshToken");

export type RefreshTokenRequest = z.infer<typeof refreshTokenSchema>;

export const updateProfileSchema = z
  .object({
    name: z.string().min(1, "Nama wajib diisi").min(8, "Nama minimal 8 karakter"),
    email: z.email("Format email tidak valid"),
  })
  .openapi("UpdateProfile");

export type UpdateProfileRequest = z.infer<typeof updateProfileSchema>;

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

export type UpdatePasswordRequest = z.infer<typeof updatePasswordSchema>;
