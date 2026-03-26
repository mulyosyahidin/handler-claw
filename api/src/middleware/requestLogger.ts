import type { Request, Response, NextFunction } from "express";
import { logger } from "../config/index.js";

export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  if (req.originalUrl === "/api/health-check") {
    return next();
  }

  const start = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - start;
    const message = `${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`;

    if (res.statusCode >= 400) {
      logger.error(message);
    } else {
      logger.info(message);
    }
  });

  next();
}
