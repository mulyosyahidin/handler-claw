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
