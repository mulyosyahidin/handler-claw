import bcrypt from "bcrypt";
import { prisma } from "../config/index.js";
import { createAccessToken } from "../lib/jose.js";
import { toUserEntity } from "../lib/mappers/index.js";
import type { LoginRequest } from "../lib/schemas/index.js";
import type { LoginResponseData } from "../lib/types/data/auth.types.js";
import {
  createSuccessResponse,
  createErrorResponse,
  type SuccessResponse,
  type ErrorResponse,
} from "../lib/types/response.js";

export class AuthService {
  async login(
    credentials: LoginRequest,
  ): Promise<SuccessResponse<LoginResponseData> | ErrorResponse<unknown>> {
    const { email, password } = credentials;

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      return createErrorResponse("Gagal login", {
        email: "Email atau password salah",
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return createErrorResponse("Gagal login", {
        password: "Email atau password salah",
      });
    }

    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    const token = await createAccessToken({
      userId: user.id,
      email: user.email,
    });

    return createSuccessResponse("Berhasil login dengan email dan password", {
      user: toUserEntity(user),
      access_token: token,
    });
  }
}
