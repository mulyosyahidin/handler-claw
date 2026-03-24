import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import type { ReminderHookService } from "../service/index.js";
import {
  createReminderHookSchema,
  getReminderHooksQuerySchema,
} from "../lib/schemas/reminder-hook.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse } from "../lib/types/response.js";

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

    const result = await this.reminderHookService.createHook(userId, parsed.data, req.headers);
    res.status(201).json(result);
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
