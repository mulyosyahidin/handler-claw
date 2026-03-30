import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import { GetFinanceOverviewUseCase } from "../../application/use-cases/get-finance-overview.use-case.js";
import { createSuccessResponse, createErrorResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";

export class FinanceOverviewController {
  constructor(private getFinanceOverviewUseCase: GetFinanceOverviewUseCase) {}

  getOverview = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    try {
      const result = await this.getFinanceOverviewUseCase.execute(userId);
      res.status(200).json(createSuccessResponse("Berhasil mengambil overview keuangan", result));
    } catch (error: any) {
      logger.error("FinanceOverviewController::getOverview() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
