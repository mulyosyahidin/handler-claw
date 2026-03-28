import type { Request, Response } from "express";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
} from "../../infrastructure/models/whatsapp-log.schema.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";
import logger from "../../../../config/logger.js";
import type { CreateWhatsappLogUseCase } from "../../application/use-cases/create-whatsapp-log.use-case.js";
import type { GetWhatsappLogsUseCase } from "../../application/use-cases/get-whatsapp-logs.use-case.js";

export class WhatsappLogController {
  constructor(
    private createWhatsappLogUseCase: CreateWhatsappLogUseCase,
    private getWhatsappLogsUseCase: GetWhatsappLogsUseCase,
  ) {}

  // POST /api/whatsapp-logs
  createLog = async (req: Request, res: Response) => {
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
      const result = await this.createWhatsappLogUseCase.execute(parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil menyimpan whatsapp log", result));
    } catch (error: any) {
      logger.error("WhatsappLogController::createLog() Error:", error);

      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/whatsapp-logs
  getLogs = async (req: Request, res: Response) => {
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
      const result = await this.getWhatsappLogsUseCase.execute(parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil mengambil whatsapp logs", result));
    } catch (error: any) {
      logger.error("WhatsappLogController::getLogs() Error:", error);

      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
