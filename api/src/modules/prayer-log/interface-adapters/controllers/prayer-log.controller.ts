import type { Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import { CreatePrayerLogUseCase } from "../../application/use-cases/create-prayer-log.use-case.js";
import { GetPrayerLogsUseCase } from "../../application/use-cases/get-prayer-logs.use-case.js";
import { GetPrayerLogsSummaryUseCase } from "../../application/use-cases/get-prayer-logs-summary.use-case.js";
import {
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
  insertLogPrayerSchema,
} from "../../infrastructure/models/prayer-log.schema.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";
import logger from "../../../../config/logger.js";

export class PrayerLogController {
  constructor(
    private createPrayerLogUseCase: CreatePrayerLogUseCase,
    private getPrayerLogsUseCase: GetPrayerLogsUseCase,
    private getPrayerLogsSummaryUseCase: GetPrayerLogsSummaryUseCase,
  ) {}

  // POST /api/prayer-logs
  insertLog = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = insertLogPrayerSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.createPrayerLogUseCase.execute(userId, parsed.data as any);
      res.status(201).json(createSuccessResponse("Berhasil mencatat jurnal solat", result));
    } catch (error: any) {
      logger.error("PrayerLogController::insertLog() Error:", error);
      if (error.message.startsWith("CONFLICT_")) {
        res.status(409).json(
          createErrorResponse("Conflict", {
            error:
              error.message === "CONFLICT_JUMAT_DZUHUR"
                ? "Sudah ada catatan Dzuhur pada hari ini."
                : "Sudah ada catatan Jumat pada hari ini.",
          }),
        );
        return;
      }

      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mencatat jurnal solat" }),
        );
    }
  };

  // GET /api/prayer-logs
  getLogs = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getPrayerLogsQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getPrayerLogsUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil jurnal solat", result));
    } catch (error: any) {
      logger.error("PrayerLogController::getLogs() Error:", error);
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mengambil jurnal solat" }),
        );
    }
  };

  // GET /api/prayer-logs/summary
  getSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getPrayerLogsSummaryQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getPrayerLogsSummaryUseCase.execute(userId, parsed.data as any);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil mengambil ringkasan jurnal solat", result));
    } catch (error: any) {
      logger.error("PrayerLogController::getSummary() Error:", error);
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil ringkasan jurnal solat",
        }),
      );
    }
  };
}
