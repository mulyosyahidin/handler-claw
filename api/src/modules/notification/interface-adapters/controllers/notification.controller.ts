import type { Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import { CreateNotificationHookUseCase } from "../../application/use-cases/create-notification-hook.use-case.js";
import { GetNotificationsUseCase } from "../../application/use-cases/get-notifications.use-case.js";
import { GetNotificationDetailUseCase } from "../../application/use-cases/get-notification-detail.use-case.js";
import { GetNotificationsSummaryUseCase } from "../../application/use-cases/get-notifications-summary.use-case.js";
import {
  createNotificationSchema,
  getNotificationParamsSchema,
  getNotificationsQuerySchema,
} from "../../infrastructure/models/notification.schema.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";

export class NotificationController {
  constructor(
    private createNotificationHookUseCase: CreateNotificationHookUseCase,
    private getNotificationsUseCase: GetNotificationsUseCase,
    private getNotificationDetailUseCase: GetNotificationDetailUseCase,
    private getNotificationsSummaryUseCase: GetNotificationsSummaryUseCase,
  ) {}

  // POST /api/notifications
  createHook = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createNotificationSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.createNotificationHookUseCase.execute(
        userId,
        parsed.data,
        req.headers,
      );

      res.status(201).json(
        createSuccessResponse("Berhasil memproses notifikasi", {
          notification: result.reminder_hook,
        }),
      );
    } catch (error: any) {
      console.error("[Notification] Gagal memproses notifikasi:", error);
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
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil daftar notifikasi",
        }),
      );
    }
  };

  // GET /api/notifications/summary
  getNotificationsSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    try {
      const result = await this.getNotificationsSummaryUseCase.execute(userId, req.query as any);

      res.status(200).json(createSuccessResponse("Berhasil mengambil summary notifikasi", result));
    } catch (error: any) {
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil summary notifikasi",
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
      const status = error.message === "Notification not found" ? 404 : 500;
      res.status(status).json(
        createErrorResponse(status === 404 ? "Not Found" : "Internal server error", {
          error: error.message,
        }),
      );
    }
  };
}
