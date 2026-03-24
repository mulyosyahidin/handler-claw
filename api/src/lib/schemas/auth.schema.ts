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
