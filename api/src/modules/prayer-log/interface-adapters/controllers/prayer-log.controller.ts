import type { Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import { CreatePrayerLogUseCase } from "../../application/use-cases/create-prayer-log.use-case.js";
import { GetPrayerLogsUseCase } from "../../application/use-cases/get-prayer-logs.use-case.js";
import { GetPrayerLogsSummaryUseCase } from "../../application/use-cases/get-prayer-logs-summary.use-case.js";
import { DeletePrayerLogUseCase } from "../../application/use-cases/delete-prayer-log.use-case.js";
import {
  deletePrayerLogParamsSchema,
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
  logPrayerSchema,
} from "../../infrastructure/models/prayer-log.schema.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";

export class PrayerLogController {
  constructor(
    private createPrayerLogUseCase: CreatePrayerLogUseCase,
    private getPrayerLogsUseCase: GetPrayerLogsUseCase,
    private getPrayerLogsSummaryUseCase: GetPrayerLogsSummaryUseCase,
    private deletePrayerLogUseCase: DeletePrayerLogUseCase,
  ) {}

  // POST /api/prayer-logs
  insertLog = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = logPrayerSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.createPrayerLogUseCase.execute(userId, parsed.data as any);
      res.status(201).json(createSuccessResponse("Berhasil mencatat jurnal solat", result));
    } catch (error: any) {
      if (error.message.startsWith("CONFLICT_")) {
        res.status(409).json(
          createErrorResponse("Conflict", {
            error:
              error.message === "CONFLICT_JUMAT_DZUHUR"
                ? "Sudah ada catatan Dzuhur pada hari ini."
                : "Sudah ada catatan Jumat pada hari ini.",
          }),
        );
        return;
      }

      console.error("[PrayerLog] Gagal mencatat jurnal solat:", error);
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mencatat jurnal solat" }),
        );
    }
  };

  // GET /api/prayer-logs
  getLogs = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getPrayerLogsQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getPrayerLogsUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil jurnal solat", result));
    } catch (error: any) {
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mengambil jurnal solat" }),
        );
    }
  };

  // GET /api/prayer-logs/summary
  getSummary = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getPrayerLogsSummaryQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getPrayerLogsSummaryUseCase.execute(userId, parsed.data as any);
      res
        .status(200)
        .json(createSuccessResponse("Berhasil mengambil ringkasan jurnal solat", result));
    } catch (error: any) {
      res.status(500).json(
        createErrorResponse("Internal server error", {
          error: "Gagal mengambil ringkasan jurnal solat",
        }),
      );
    }
  };

  // DELETE /api/prayer-logs/:id
  deleteLog = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = deletePrayerLogParamsSchema.safeParse(req.params);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      await this.deletePrayerLogUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil menghapus jurnal solat", null));
    } catch (error: any) {
      const status = error.message === "Prayer log not found" ? 404 : 500;
      res.status(status).json(
        createErrorResponse(status === 404 ? "Not Found" : "Internal server error", {
          error: error.message,
        }),
      );
    }
  };
}
