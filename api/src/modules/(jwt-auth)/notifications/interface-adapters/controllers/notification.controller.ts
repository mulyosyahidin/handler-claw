import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import { CreateNotificationWebhookUseCase } from "../../../../_shared/notifications/application/use-cases/create-notification-webhook.use-case.js";
import { GetNotificationsUseCase } from "../../../../_shared/notifications/application/use-cases/get-notifications.use-case.js";
import { GetNotificationDetailUseCase } from "../../../../_shared/notifications/application/use-cases/get-notification-detail.use-case.js";
import { createNotificationWebhookSchema } from "../../../../_shared/notifications/infrastructure/models/notification-webhook.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import {
  getNotificationParamsSchema,
  getNotificationsQuerySchema,
} from "../../../../_shared/notifications/infrastructure/models/notification.schema.js";

export class NotificationController {
  constructor(
    private createNotificationWebhookUseCase: CreateNotificationWebhookUseCase,
    private getNotificationsUseCase: GetNotificationsUseCase,
    private getNotificationDetailUseCase: GetNotificationDetailUseCase,
  ) {}

  // POST /api/notifications
  createNotificationWebhook = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createNotificationWebhookSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.createNotificationWebhookUseCase.execute(userId, parsed.data);

      res.status(201).json(createSuccessResponse("Berhasil memproses notifikasi", result));
    } catch (error: any) {
      logger.error("NotificationController::createNotificationWebhook() Error:", error);

      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal memproses notifikasi" }),
        );
    }
  };

  // GET /api/notifications
  getNotifications = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getNotificationsQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getNotificationsUseCase.execute(userId, parsed.data as any);

      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar notifikasi", result));
    } catch (error: any) {
      logger.error("NotificationController::getNotifications() Error:", error);

      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil daftar notifikasi",
        }),
      );
    }
  };

  // GET /api/notifications/:id
  getNotificationDetails = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getNotificationParamsSchema.safeParse(req.params);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getNotificationDetailUseCase.execute(userId, parsed.data.id);

      res.status(200).json(createSuccessResponse("Berhasil mengambil detail notifikasi", result));
    } catch (error: any) {
      logger.error("NotificationController::getNotificationDetails() Error:", error);

      const status = error.message === "Notification not found" ? 404 : 500;
      res.status(status).json(
        createErrorResponse(status === 404 ? "Not Found" : "Internal server error", {
          error: error.message,
        }),
      );
    }
  };
}
