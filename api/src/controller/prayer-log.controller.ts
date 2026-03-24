import type { Request, Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import type { PrayerLogService } from "../service/index.js";
import { logPrayerSchema } from "../lib/schemas/index.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse } from "../lib/types/response.js";
import type { SummaryType } from "../lib/types/data/prayer-log.types.js";

const VALID_SUMMARY_TYPES: SummaryType[] = [
  "daily",
  "weekly",
  "monthly",
  "yearly",
  "all",
  "custom",
];

export class PrayerLogController {
  private prayerLogService: PrayerLogService;

  constructor(prayerLogService: PrayerLogService) {
    this.prayerLogService = prayerLogService;
  }

  insertLog = async (req: AuthRequest, res: Response) => {
    const user = req.user;
    if (!user) {
      res.status(401).json(
        createErrorResponse("Unauthorized", {
          token: "Token tidak valid",
        }),
      );
      return;
    }

    const insertLogInput = logPrayerSchema.safeParse(req.body);

    if (!insertLogInput.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(insertLogInput.error),
        }),
      );
      return;
    }

    const result = await this.prayerLogService.insertLog(user.userId, insertLogInput.data);

    res.status(200).json(result);
  };

  getLogs = async (req: AuthRequest, res: Response) => {
    const user = req.user;
    if (!user) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const result = await this.prayerLogService.getLogs(user.userId);
    res.status(200).json(result);
  };

  getSummary = async (req: Request, res: Response) => {
    const user = (req as AuthRequest).user;
    if (!user) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const rawType = (req.query["type"] as string | undefined) || "all";

    if (!VALID_SUMMARY_TYPES.includes(rawType as SummaryType)) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          type: `Tipe tidak valid. Gunakan salah satu dari: ${VALID_SUMMARY_TYPES.join(", ")}`,
        }),
      );
      return;
    }

    const type = rawType as SummaryType;
    let startDate: Date | undefined;
    let endDate: Date | undefined;

    if (type === "custom") {
      const rawStart = req.query["start_date"] as string | undefined;
      const rawEnd = req.query["end_date"] as string | undefined;

      if (!rawStart || !rawEnd) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            start_date: !rawStart ? "start_date wajib diisi untuk tipe custom" : undefined,
            end_date: !rawEnd ? "end_date wajib diisi untuk tipe custom" : undefined,
          }),
        );
        return;
      }

      startDate = new Date(rawStart);
      endDate = new Date(rawEnd);

      if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            date: "Format tanggal tidak valid. Gunakan format YYYY-MM-DD",
          }),
        );
        return;
      }

      if (startDate > endDate) {
        res.status(422).json(
          createErrorResponse("Validation error", {
            start_date: "start_date tidak boleh lebih besar dari end_date",
          }),
        );
        return;
      }
    }

    const result = await this.prayerLogService.getSummary(user.userId, type, startDate, endDate);
    res.status(200).json(result);
  };
}
