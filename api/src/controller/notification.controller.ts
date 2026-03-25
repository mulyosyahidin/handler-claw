import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import { userDeviceService, type NotificationService } from "../service/index.js";
import {
  createNotificationSchema,
  getNotificationParamsSchema,
  getNotificationsQuerySchema,
} from "../lib/schemas/notification.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../lib/types/response.js";
import { toNotificationEntity } from "../lib/mappers/notification.mapper.js";

export class NotificationController {
  private notificationService: NotificationService;

  constructor(notificationService: NotificationService) {
    this.notificationService = notificationService;
  }

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

    const reminderHook = await this.notificationService.createNotificationHook(
      userId,
      parsed.data,
      req.headers,
    );

    try {
      const allUserDevices = await userDeviceService.findAllUserDevices(userId);

      for (const device of allUserDevices) {
        const notification = await this.notificationService.create({
          reminder_hook_id: reminderHook.id,
          user_id: userId,
          user_device_id: device.id,
          title: parsed.data.title,
          body: parsed.data.message,
          data: {
            reminder_hook_id: reminderHook.id,
            event_id: parsed.data.event_id,
            type: parsed.data.type,
            link_to: parsed.data.link_to,
            created_at: reminderHook.createdAt.toISOString(),
          },
        });

        await this.notificationService.sendNotification(notification);
      }
      res.status(201).json(
        createSuccessResponse("Berhasil memproses notifikasi", {
          notification: toNotificationEntity(reminderHook),
        }),
      );
    } catch (error) {
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

    const result = await this.notificationService.getNotifications(userId, parsed.data);
    res.status(200).json(result);
  };

  // GET /api/notifications/summary
  getNotificationsSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const result = await this.notificationService.getNotificationsSummary(userId);
    res.status(200).json(result);
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
      const result = await this.notificationService.getNotificationDetails(userId, parsed.data.id);

      if (!result.data) {
        res.status(404).json(result);
        return;
      }

      res.status(200).json({
        ...result,
        data: {
          notification: result.data.notification,
        },
      });
    } catch (error: any) {
      if (error.success === false) {
        res.status(404).json(error);
        return;
      }
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", {
            error: "Gagal mengambil detail notifikasi",
          }),
        );
    }
  };
}
