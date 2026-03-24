import type { Request, Response } from "express";
import type { WhatsappLogService } from "../service/index.js";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../lib/schemas/whatsapp-log.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse } from "../lib/types/response.js";

export class WhatsappLogController {
  private whatsappLogService: WhatsappLogService;

  constructor(whatsappLogService: WhatsappLogService) {
    this.whatsappLogService = whatsappLogService;
  }

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

    const result = await this.whatsappLogService.createLog(parsed.data);
    res.status(201).json(result);
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

    const result = await this.whatsappLogService.getLogs(parsed.data);
    res.status(200).json(result);
  };

  // GET /api/whatsapp-logs/summary
  getSummary = async (req: Request, res: Response) => {
    const parsed = getWhatsappLogsSummaryQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const result = await this.whatsappLogService.getSummary();
    res.status(200).json(result);
  };
}
