import type { Request, Response, NextFunction } from "express";
import { verifyAccessToken, type TokenPayload } from "../lib/jose.js";
import { createErrorResponse } from "../lib/types/response.js";
import logger from "../config/logger.js";

export interface AuthRequest extends Request {
  user?: TokenPayload;
}

export async function authMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    res.status(401).json(
      createErrorResponse("Unauthorized", {
        token: "Token tidak ditemukan",
      }),
    );
    return;
  }

  const token = authHeader.split(" ")[1];

  if (!token) {
    res.status(401).json(
      createErrorResponse("Unauthorized", {
        token: "Token tidak ditemukan",
      }),
    );
    return;
  }

  try {
    const payload = await verifyAccessToken(token);
    req.user = payload;
    req.userId = payload.userId;
    req.email = payload.email;
    next();
  } catch (error: any) {
    logger.error(error.message);

    res.status(401).json(
      createErrorResponse("Unauthorized", {
        token: "Token tidak valid atau sudah expired",
      }),
    );
  }
}
