import type { Response } from "express";
import type { ApiKeyRequest } from "../../../../../middleware/api-key.middleware.js";
import { CreatePrayerLogUseCase } from "../../../../_shared/prayer-logs/application/use-cases/create-prayer-log.use-case.js";
import { GetPrayerLogsUseCase } from "../../../../_shared/prayer-logs/application/use-cases/get-prayer-logs.use-case.js";
import { GetPrayerLogsSummaryUseCase } from "../../../../_shared/prayer-logs/application/use-cases/get-prayer-logs-summary.use-case.js";
import {
  insertLogPrayerSchema,
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
} from "../../../../_shared/prayer-logs/infrastructure/models/prayer-log.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import prisma from "../../../../../config/prisma.js";
import { hashApiKey } from "../../../../../lib/api-key.js";

export class AppPrayerLogController {
  constructor(
    private createPrayerLogUseCase: CreatePrayerLogUseCase,
    private getPrayerLogsUseCase: GetPrayerLogsUseCase,
    private getPrayerLogsSummaryUseCase: GetPrayerLogsSummaryUseCase,
  ) {}

  // POST /api/app/prayer-logs
  insertLog = async (req: ApiKeyRequest, res: Response) => {
    try {
      // 1. Validasi API Key (dari middleware api-key.middleware.ts, dipastikan string)
      const apiKey = req.apiKey!;
      const hashedKey = hashApiKey(apiKey);

      const apiKeyRecord = await prisma.apiKey.findFirst({
        where: { keyFull: hashedKey, status: "ACTIVE", deletedAt: null },
      });

      if (!apiKeyRecord) {
        res.status(401).json(
          createErrorResponse("Unauthorized", {
            token: "API Key tidak valid atau telah dicabut",
          }),
        );
        return;
      }

      const userId = apiKeyRecord.userId;

      // 2. Validasi Body
      const parsed = insertLogPrayerSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      // 3. Eksekusi Use Case
      const result = await this.createPrayerLogUseCase.execute(userId, parsed.data as any);
      res.status(201).json(createSuccessResponse("Berhasil mencatat jurnal solat", result));
    } catch (error: any) {
      logger.error("AppPrayerLogController::insertLog() Error:", error);
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

      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mencatat jurnal solat via API Key",
        }),
      );
    }
  };

  // GET /api/app/prayer-logs
  getLogs = async (req: ApiKeyRequest, res: Response) => {
    try {
      const apiKey = req.apiKey!;
      const hashedKey = hashApiKey(apiKey);

      const apiKeyRecord = await prisma.apiKey.findFirst({
        where: { keyFull: hashedKey, status: "ACTIVE", deletedAt: null },
      });

      if (!apiKeyRecord) {
        res.status(401).json(
          createErrorResponse("Unauthorized", {
            token: "API Key tidak valid atau telah dicabut",
          }),
        );
        return;
      }

      const userId = apiKeyRecord.userId;

      const parsed = getPrayerLogsQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      const result = await this.getPrayerLogsUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil jurnal solat", result));
    } catch (error: any) {
      logger.error("AppPrayerLogController::getLogs() Error:", error);
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil jurnal solat via API Key",
        }),
      );
    }
  };

  // GET /api/app/prayer-logs/summary
  getSummary = async (req: ApiKeyRequest, res: Response) => {
    try {
      const apiKey = req.apiKey!;
      const hashedKey = hashApiKey(apiKey);

      const apiKeyRecord = await prisma.apiKey.findFirst({
        where: { keyFull: hashedKey, status: "ACTIVE", deletedAt: null },
      });

      if (!apiKeyRecord) {
        res.status(401).json(
          createErrorResponse("Unauthorized", {
            token: "API Key tidak valid atau telah dicabut",
          }),
        );
        return;
      }

      const userId = apiKeyRecord.userId;

      const parsed = getPrayerLogsSummaryQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      const result = await this.getPrayerLogsSummaryUseCase.execute(userId, parsed.data as any);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil mengambil ringkasan jurnal solat", result));
    } catch (error: any) {
      logger.error("AppPrayerLogController::getSummary() Error:", error);
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil ringkasan jurnal solat via API Key",
        }),
      );
    }
  };
}
