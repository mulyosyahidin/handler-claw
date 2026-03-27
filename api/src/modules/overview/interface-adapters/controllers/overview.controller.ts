import type { Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import { GetOverviewUseCase } from "../../application/use-cases/get-overview.use-case.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";

export class OverviewController {
  constructor(private getOverviewUseCase: GetOverviewUseCase) {}

  // GET /api/overview
  getOverview = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    try {
      const result = await this.getOverviewUseCase.execute(userId);
      res.status(200).json(createSuccessResponse("Berhasil mengambil data overview", result));
    } catch (error: any) {
      console.error("[Overview] Gagal mengambil data overview:", error);
      res
        .status(500)
        .json(
          createErrorResponse("Internal server error", { error: "Gagal mengambil data overview" }),
        );
    }
  };
}
