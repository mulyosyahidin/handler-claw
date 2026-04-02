import type { Request, Response, NextFunction } from "express";
import { createErrorResponse } from "../lib/types/response.js";

export interface ApiKeyRequest extends Request {
  apiKey?: string;
}

export function apiKeyMiddleware(req: ApiKeyRequest, res: Response, next: NextFunction): void {
  const apiKey = req.headers["x-api-key"];

  if (!apiKey || typeof apiKey !== "string") {
    res.status(401).json(
      createErrorResponse("Unauthorized", {
        token: "API Key tidak ditemukan di header (x-api-key)",
      }),
    );
    return;
  }

  req.apiKey = apiKey;
  next();
}
