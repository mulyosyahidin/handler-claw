import type { Request, Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../../../../_shared/whatsapp-logs/infrastructure/models/whatsapp-log.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import type { CreateWhatsappLogUseCase } from "../../../../_shared/whatsapp-logs/application/use-cases/create-whatsapp-log.use-case.js";
import type { GetWhatsappLogsUseCase } from "../../../../_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs.use-case.js";
import type { GetWhatsappLogsSummaryUseCase } from "../../../../_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs-summary.use-case.js";
import type { WebhookLoggerService } from "../../../../_shared/whatsapp-logs/infrastructure/services/webhook-logger.service.js";

export class WhatsappLogController {
  constructor(
    private createWhatsappLogUseCase: CreateWhatsappLogUseCase,
    private getWhatsappLogsUseCase: GetWhatsappLogsUseCase,
    private getWhatsappLogsSummaryUseCase: GetWhatsappLogsSummaryUseCase,
    private webhookLoggerService: WebhookLoggerService,
  ) {}

  // POST /api/whatsapp-logs
  createLog = async (req: Request, res: Response) => {
    // Log the webhook to file
    this.webhookLoggerService.log(req.headers, req.body);

    const parsed = createWhatsappLogSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const userId = req.params.userId || req.query.user_id;

      const result = await this.createWhatsappLogUseCase.execute(
        typeof userId === "string" ? userId : null,
        parsed.data,
      );
      res.status(201).json(createSuccessResponse("Berhasil menyimpan whatsapp log", result));
    } catch (error: any) {
      logger.error("WhatsappLogController::createLog() Error:", error);

      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/whatsapp-logs
  getLogs = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", null));
      return;
    }

    const parsed = getWhatsappLogsQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getWhatsappLogsUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil whatsapp logs", result));
    } catch (error: any) {
      logger.error("WhatsappLogController::getLogs() Error:", error);

      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/whatsapp-logs/summary
  getSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", null));
      return;
    }

    const parsed = getWhatsappLogsSummaryQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getWhatsappLogsSummaryUseCase.execute(userId, parsed.data as any);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil mengambil summary whatsapp logs", result));
    } catch (error: any) {
      logger.error("WhatsappLogController::getSummary() Error:", error);

      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
