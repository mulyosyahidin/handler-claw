import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import { userDeviceService, type ReminderHookService } from "../service/index.js";
import {
  createReminderHookSchema,
  getReminderHooksQuerySchema,
} from "../lib/schemas/reminder-hook.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../lib/types/response.js";
import { toReminderHookEntity } from "../lib/mappers/reminder-hook.mapper.js";
import { notificationService } from "../service/notification.service.js";

export class ReminderHookController {
  private reminderHookService: ReminderHookService;

  constructor(reminderHookService: ReminderHookService) {
    this.reminderHookService = reminderHookService;
  }

  // POST /api/reminder-hooks
  createHook = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createReminderHookSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const reminderHook = await this.reminderHookService.createHook(
      userId,
      parsed.data,
      req.headers,
    );

    try {
      const allUserDevices = await userDeviceService.findAllUserDevices(userId);

      for (const device of allUserDevices) {
        const notification = await notificationService.create({
          reminder_hook_id: reminderHook.id,
          user_id: userId,
          user_device_id: device.id,
          title: parsed.data.title,
          body: parsed.data.message,
          data: {
            event_id: parsed.data.event_id,
            type: parsed.data.type,
            link_to: parsed.data.link_to,
          },
        });

        await notificationService.sendNotification(notification);
      }
      res.status(201).json(
        createSuccessResponse("Berhasil memproses hook", {
          reminder_hook: toReminderHookEntity(reminderHook),
        }),
      );
    } catch (error) {
      console.error("[Webhook] Gagal memproses hook:", error);

      res
        .status(500)
        .json(createErrorResponse("Internal server error", { error: "Gagal memproses hook" }));
    }
  };

  // GET /api/reminder-hooks
  getHooks = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getReminderHooksQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const result = await this.reminderHookService.getHooks(userId, parsed.data);
    res.status(200).json(result);
  };

  // GET /api/reminder-hooks/summary
  getHooksSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const result = await this.reminderHookService.getHooksSummary(userId);
    res.status(200).json(result);
  };
}
