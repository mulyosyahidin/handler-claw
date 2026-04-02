import type { Response } from "express";
import type { ApiKeyRequest } from "../../../../../middleware/api-key.middleware.js";
import { CreateNotificationWebhookUseCase } from "../../../../_shared/notifications/application/use-cases/create-notification-webhook.use-case.js";
import { createNotificationWebhookSchema } from "../../../../_shared/notifications/infrastructure/models/notification-webhook.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import prisma from "../../../../../config/prisma.js";
import { hashApiKey } from "../../../../../lib/api-key.js";

export class AppNotificationController {
  constructor(private createNotificationWebhookUseCase: CreateNotificationWebhookUseCase) {}

  // POST /api/app/notifications
  createNotificationWebhook = async (req: ApiKeyRequest, res: Response) => {
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

      const parsed = createNotificationWebhookSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            errors: zodErrorMapper(parsed.error),
          }),
        );
        return;
      }

      const result = await this.createNotificationWebhookUseCase.execute(userId, parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil memproses notifikasi", result));
    } catch (error: any) {
      logger.error("AppNotificationController::createNotificationWebhook() Error:", error);
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", {
            error: "Gagal memproses notifikasi via API Key",
          }),
        );
    }
  };
}
