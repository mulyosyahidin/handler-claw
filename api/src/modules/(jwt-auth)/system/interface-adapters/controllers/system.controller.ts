import type { Request, Response } from "express";
import { createSuccessResponse } from "../../../../../lib/types/response.js";
import type { HealthCheckUseCase } from "../../application/use-cases/health-check.use-case.js";

export class SystemController {
  constructor(private healthCheckUseCase: HealthCheckUseCase) {}

  welcome = async (_req: Request, res: Response) => {
    res.json(createSuccessResponse("Welcome to the HandlerClaw API"));
  };

  healthCheck = async (_req: Request, res: Response) => {
    const result = await this.healthCheckUseCase.execute();
    res.json(createSuccessResponse("OK", result));
  };
}
