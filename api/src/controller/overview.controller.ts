import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import { type OverviewService } from "../service/index.js";
import { createErrorResponse } from "../lib/types/response.js";

export class OverviewController {
  private overviewService: OverviewService;

  constructor(overviewService: OverviewService) {
    this.overviewService = overviewService;
  }

  // GET /api/overview
  getOverview = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    try {
      const result = await this.overviewService.getOverview(userId);
      res.status(200).json(result);
    } catch (error) {
      console.error("[Overview] Gagal mengambil data overview:", error);
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mengambil data overview" }),
        );
    }
  };
}
