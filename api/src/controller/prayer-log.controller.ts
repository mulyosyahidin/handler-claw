import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import type { PrayerLogService } from "../service/index.js";
import {
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
  logPrayerSchema,
} from "../lib/schemas/prayer-log.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse } from "../lib/types/response.js";

export class PrayerLogController {
  private prayerLogService: PrayerLogService;

  constructor(prayerLogService: PrayerLogService) {
    this.prayerLogService = prayerLogService;
  }

  insertLog = async (req: AuthRequest, res: Response) => {
    const user = req.user;
    if (!user) {
      res.status(401).json(
        createErrorResponse("Unauthorized", {
          token: "Token tidak valid",
        }),
      );
      return;
    }

    const insertLogInput = logPrayerSchema.safeParse(req.body);

    if (!insertLogInput.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(insertLogInput.error),
        }),
      );
      return;
    }

    const result = await this.prayerLogService.insertLog(user.userId, insertLogInput.data);

    res.status(200).json(result);
  };

  getLogs = async (req: AuthRequest, res: Response) => {
    const user = req.user;
    if (!user) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const queryInput = getPrayerLogsQuerySchema.safeParse(req.query);
    if (!queryInput.success) {
      res
        .status(422)
        .json(
          createErrorResponse("Validation error", { errors: zodErrorMapper(queryInput.error) }),
        );
      return;
    }

    const result = await this.prayerLogService.getLogs(user.userId, queryInput.data);
    res.status(200).json(result);
  };

  getSummary = async (req: AuthRequest, res: Response) => {
    const user = req.user;
    if (!user) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const queryInput = getPrayerLogsSummaryQuerySchema.safeParse(req.query);
    if (!queryInput.success) {
      res
        .status(422)
        .json(
          createErrorResponse("Validation error", { errors: zodErrorMapper(queryInput.error) }),
        );
      return;
    }

    const result = await this.prayerLogService.getSummary(user.userId, queryInput.data);
    res.status(200).json(result);
  };
}
