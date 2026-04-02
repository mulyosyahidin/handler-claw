import type { Request, Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import {
  loginSchema,
  refreshTokenSchema,
  updateProfileSchema,
  updatePasswordSchema,
} from "../../infrastructure/models/auth.schema.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { LoginUseCase } from "../../application/use-cases/login.use-case.js";
import { RefreshTokenUseCase } from "../../application/use-cases/refresh-token.use-case.js";
import { GetMeUseCase } from "../../application/use-cases/get-me.use-case.js";
import { UpdateProfileUseCase } from "../../application/use-cases/update-profile.use-case.js";
import { UpdatePasswordUseCase } from "../../application/use-cases/update-password.use-case.js";
import { GoogleLoginUseCase } from "../../application/use-cases/google-login.use-case.js";
import { UpdateAvatarUseCase } from "../../application/use-cases/update-avatar.use-case.js";
import { googleLoginSchema, updateAvatarSchema } from "../../infrastructure/models/auth.schema.js";
import logger from "../../../../config/logger.js";

export class AuthController {
  constructor(
    private loginUseCase: LoginUseCase,
    private refreshTokenUseCase: RefreshTokenUseCase,
    private getMeUseCase: GetMeUseCase,
    private updateProfileUseCase: UpdateProfileUseCase,
    private updatePasswordUseCase: UpdatePasswordUseCase,
    private googleLoginUseCase: GoogleLoginUseCase,
    private updateAvatarUseCase: UpdateAvatarUseCase,
  ) {}

  login = async (req: Request, res: Response) => {
    const parsed = loginSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json(
        createErrorResponse("Validation failed", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.loginUseCase.execute(parsed.data);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil login dengan email dan password", result));
    } catch (error: any) {
      logger.error("AuthController::login() Error:", error);
      res.status(401).json(createErrorResponse(error.message, error.errors));
    }
  };

  googleLogin = async (req: Request, res: Response) => {
    const parsed = googleLoginSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(400).json(
        createErrorResponse("Validation failed", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.googleLoginUseCase.execute(parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil login dengan Google", result));
    } catch (error: any) {
      logger.error("AuthController::googleLogin() Error:", error);
      res.status(401).json(createErrorResponse(error.message, error.errors));
    }
  };

  refreshToken = async (req: Request, res: Response) => {
    const parsed = refreshTokenSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const { refresh_token } = parsed.data;
    try {
      const result = await this.refreshTokenUseCase.execute(refresh_token);
      res.status(200).json(createSuccessResponse("Access token berhasil diperbarui", result));
    } catch (error: any) {
      logger.error("AuthController::refreshToken() Error:", error);
      res.status(401).json(createErrorResponse(error.message, error.errors));
    }
  };

  getMe = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res
        .status(401)
        .json(createErrorResponse("Unauthorized", { token: "Token tidak valid atau kadaluarsa" }));
      return;
    }

    try {
      const result = await this.getMeUseCase.execute(userId);
      res.status(200).json(createSuccessResponse("Berhasil mengambil profil user", result));
    } catch (error: any) {
      logger.error("AuthController::getMe() Error:", error);
      res.status(404).json(createErrorResponse(error.message, error.errors));
    }
  };

  updateProfile = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res
        .status(401)
        .json(createErrorResponse("Unauthorized", { token: "Token tidak valid atau kadaluarsa" }));
      return;
    }

    const parsed = updateProfileSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation failed", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.updateProfileUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Profil berhasil diperbarui", result));
    } catch (error: any) {
      logger.error("AuthController::updateProfile() Error:", error);
      res.status(422).json(createErrorResponse(error.message, error.errors));
    }
  };

  updatePassword = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res
        .status(401)
        .json(createErrorResponse("Unauthorized", { token: "Token tidak valid atau kadaluarsa" }));
      return;
    }

    const parsed = updatePasswordSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation failed", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      await this.updatePasswordUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Password berhasil diperbarui"));
    } catch (error: any) {
      logger.error("AuthController::updatePassword() Error:", error);
      res.status(422).json(createErrorResponse(error.message, error.errors));
    }
  };

  updateAvatar = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res
        .status(401)
        .json(createErrorResponse("Unauthorized", { token: "Token tidak valid atau kadaluarsa" }));
      return;
    }

    const parsed = updateAvatarSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation failed", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.updateAvatarUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Avatar berhasil diperbarui", result));
    } catch (error: any) {
      logger.error("AuthController::updateAvatar() Error:", error);
      res.status(422).json(createErrorResponse(error.message, error.errors));
    }
  };
}
