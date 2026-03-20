import type { Request, Response } from "express";
import type { AuthService } from "../service/index.js";
import { loginSchema } from "../lib/schemas/index.js";
import { createErrorResponse } from "../lib/types/response.js";

export class AuthController {
  private authService: AuthService;

  constructor(authService: AuthService) {
    this.authService = authService;
  }

  login = async (req: Request, res: Response) => {
    const parseResult = loginSchema.safeParse(req.body);

    if (!parseResult.success) {
      const errors = parseResult.error.flatten().fieldErrors;
      res.status(400).json(createErrorResponse("Validation failed", errors));
      return;
    }

    const result = await this.authService.login(parseResult.data);

    if (result.success) {
      res.status(200).json(result);
    } else {
      res.status(401).json(result);
    }
  };
}
