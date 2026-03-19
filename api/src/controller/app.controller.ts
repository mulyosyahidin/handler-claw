import type { Request, Response } from "express";
import type { AppService } from "@/service/app.service";
import { createSuccessResponse, type ApiResponse } from "@/lib/types/response";

export class AppController {
  private appService: AppService;

  constructor(appService: AppService) {
    this.appService = appService;
  }

  welcome = async (_req: Request, res: Response) => {
    res.json(createSuccessResponse("Welcome to the HandlerClaw API"));
  };

  healthCheck = async (_req: Request, res: Response) => {
    const healthCheck: ApiResponse<{ timestamp: string }> = await this.appService.healthCheck();

    res.json(healthCheck);
  };
}
