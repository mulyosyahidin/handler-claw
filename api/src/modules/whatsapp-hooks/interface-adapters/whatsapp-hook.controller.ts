import type { Request, Response } from "express";
import { createErrorResponse, createSuccessResponse } from "../../../lib/types/response.js";
import { createWebhookLogSchema } from "../../_shared/whatsapp-hooks/infrastructure/models/whatsapp-hook.schema.js";
import { zodErrorMapper } from "../../../utils/zod.js";
import logger from "../../../config/logger.js";
import type { CreateWebhookLogUseCase } from "../../_shared/whatsapp-hooks/application/use-cases/create-webhook-log.use-case.js";
import type { CreateWhatsappMessageUseCase } from "../../_shared/whatsapp-hooks/application/use-cases/create-whatsapp-message.use-case.js";
import type { CreateWebhookLogData } from "../../_shared/whatsapp-hooks/application/dtos/whatsapp-hook.dto.js";
import { WebhookLoggerService } from "../../_shared/whatsapp-hooks/infrastructure/services/webhook-logger.service.js";

export class WhatsappHookController {
  constructor(
    private createWebhookLogUseCase: CreateWebhookLogUseCase,
    private createWhatsappMessageUseCase: CreateWhatsappMessageUseCase,
    private webhookLogger: WebhookLoggerService,
  ) {}

  handleIncomingMessage = async (req: Request, res: Response) => {
    this.webhookLogger.log(req.headers, req.body);
    const userId = req.params.userId || req.query.user_id;

    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { user_id: "User ID tidak valid" }));
      return;
    }

    const parsed = createWebhookLogSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const data: CreateWebhookLogData = {
        deviceId: parsed.data.device_id,
        event: parsed.data.event,
        payload: parsed.data.payload,
      };

      const result = await this.createWebhookLogUseCase.execute(
        typeof userId === "string" ? userId : null,
        data,
      );

      if (result.webhook_log) {
        const message = await this.createWhatsappMessageUseCase.execute(
          result.webhook_log.id,
          result.webhook_log.payload as any,
        );
        result.message = message;
      }

      res.status(201).json(createSuccessResponse("Berhasil memproses webhook", result));
    } catch (error: any) {
      logger.error("WhatsappHookController::handleIncomingMessage() Error", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
