import type { Response } from "express";
import type { ApiKeyRequest } from "../../../../../middleware/api-key.middleware.js";
import {
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../../../../_shared/whatsapp-logs/infrastructure/models/whatsapp-log.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import prisma from "../../../../../config/prisma.js";
import { hashApiKey } from "../../../../../lib/api-key.js";
import type { GetWhatsappLogsUseCase } from "../../../../_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs.use-case.js";
import type { GetWhatsappLogsSummaryUseCase } from "../../../../_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs-summary.use-case.js";

export class AppWhatsappLogController {
  constructor(
    private getWhatsappLogsUseCase: GetWhatsappLogsUseCase,
    private getWhatsappLogsSummaryUseCase: GetWhatsappLogsSummaryUseCase,
  ) {}

  private async validateApiKey(req: ApiKeyRequest, res: Response): Promise<string | null> {
    const apiKey = req.apiKey!;
    const hashedKey = hashApiKey(apiKey);

    const apiKeyRecord = await prisma.apiKey.findFirst({
      where: { keyFull: hashedKey, status: "ACTIVE", deletedAt: null },
    });

    if (!apiKeyRecord) {
      res
        .status(401)
        .json(
          createErrorResponse("Unauthorized", { token: "API Key tidak valid atau telah dicabut" }),
        );
      return null;
    }

    return apiKeyRecord.userId;
  }

  // GET /api/app/whatsapp-logs
  getLogs = async (req: ApiKeyRequest, res: Response) => {
    try {
      const userId = await this.validateApiKey(req, res);
      if (!userId) return;

      const parsed = getWhatsappLogsQuerySchema.safeParse(req.query);

      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      const result = await this.getWhatsappLogsUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil whatsapp logs (App)", result));
    } catch (error: any) {
      logger.error("AppWhatsappLogController::getLogs() Error:", error);
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil log via API Key",
        }),
      );
    }
  };

  // GET /api/app/whatsapp-logs/summary
  getSummary = async (req: ApiKeyRequest, res: Response) => {
    try {
      const userId = await this.validateApiKey(req, res);
      if (!userId) return;

      const parsed = getWhatsappLogsSummaryQuerySchema.safeParse(req.query);

      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      const result = await this.getWhatsappLogsSummaryUseCase.execute(userId, parsed.data as any);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil mengambil summary whatsapp logs (App)", result));
    } catch (error: any) {
      logger.error("AppWhatsappLogController::getSummary() Error:", error);
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil summary via API Key",
        }),
      );
    }
  };
}
