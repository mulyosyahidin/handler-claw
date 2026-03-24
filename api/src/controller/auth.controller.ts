import type { Request, Response } from "express";
import type { AuthService } from "../service/index.js";
import { loginSchema, refreshTokenSchema } from "../lib/schemas/index.js";
import { createErrorResponse } from "../lib/types/response.js";
import { zodErrorMapper } from "../utils/zod.js";

export class AuthController {
  private authService: AuthService;

  constructor(authService: AuthService) {
    this.authService = authService;
  }

  login = async (req: Request, res: Response) => {
    const parsed = loginSchema.safeParse(req.body);

    if (!parsed.success) {
      const errors = parsed.error.flatten().fieldErrors;
      res.status(400).json(createErrorResponse("Validation failed", errors));
      return;
    }

    const result = await this.authService.login(parsed.data);

    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(401).json(result);
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
    const result = await this.authService.refreshToken(refresh_token);

    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(401).json(result);
    }
  };
}
