import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import {
  createApiKeySchema,
  updateApiKeySchema,
  getApiKeysQuerySchema,
  apiKeyParamsSchema,
} from "../../infrastructure/models/api-key.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import type { CreateApiKeyUseCase } from "../../application/use-cases/create-api-key.use-case.js";
import type { GetApiKeysUseCase } from "../../application/use-cases/get-api-keys.use-case.js";
import type { GetApiKeyDetailUseCase } from "../../application/use-cases/get-api-key-detail.use-case.js";
import type { DeleteApiKeyUseCase } from "../../application/use-cases/delete-api-key.use-case.js";
import type { RevokeApiKeyUseCase } from "../../application/use-cases/revoke-api-key.use-case.js";
import type { RotateApiKeyUseCase } from "../../application/use-cases/rotate-api-key.use-case.js";
import type { UpdateApiKeyUseCase } from "../../application/use-cases/update-api-key.use-case.js";
import logger from "../../../../../config/logger.js";
import { NotFoundError } from "../../../../../lib/errors/not-found.error.js";

export class ApiKeyController {
  constructor(
    private createApiKeyUseCase: CreateApiKeyUseCase,
    private getApiKeysUseCase: GetApiKeysUseCase,
    private getApiKeyDetailUseCase: GetApiKeyDetailUseCase,
    private deleteApiKeyUseCase: DeleteApiKeyUseCase,
    private revokeApiKeyUseCase: RevokeApiKeyUseCase,
    private rotateApiKeyUseCase: RotateApiKeyUseCase,
    private updateApiKeyUseCase: UpdateApiKeyUseCase,
  ) {}

  // POST /api/api-keys
  createKey = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createApiKeySchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.createApiKeyUseCase.execute(userId, parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil membuat API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::createKey() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/api-keys
  getKeys = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getApiKeysQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getApiKeysUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::getKeys() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/api-keys/:id
  getKeyById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = apiKeyParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getApiKeyDetailUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil mengambil detail API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::getKeyById() Error:", error);
      if (error instanceof NotFoundError) {
        res.status(404).json(createErrorResponse(error.message, null));
      } else {
        res.status(500).json(createErrorResponse(error.message, null));
      }
    }
  };

  // DELETE /api/api-keys/:id
  deleteKey = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = apiKeyParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    try {
      await this.deleteApiKeyUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil menghapus API Key"));
    } catch (error: any) {
      logger.error("ApiKeyController::deleteKey() Error:", error);
      if (error instanceof NotFoundError) {
        res.status(404).json(createErrorResponse(error.message, null));
      } else {
        res.status(500).json(createErrorResponse(error.message, null));
      }
    }
  };

  // PATCH /api/api-keys/:id/revoke
  revokeKey = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = apiKeyParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    try {
      const result = await this.revokeApiKeyUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil me-revoke API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::revokeKey() Error:", error);
      if (error instanceof NotFoundError) {
        res.status(404).json(createErrorResponse(error.message, null));
      } else {
        res.status(500).json(createErrorResponse(error.message, null));
      }
    }
  };

  // PATCH /api/api-keys/:id/rotate
  rotateKey = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = apiKeyParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    try {
      const result = await this.rotateApiKeyUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil me-rotate API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::rotateKey() Error:", error);
      if (error instanceof NotFoundError) {
        res.status(404).json(createErrorResponse(error.message, null));
      } else {
        res.status(500).json(createErrorResponse(error.message, null));
      }
    }
  };

  // PATCH /api/api-keys/:id
  updateKey = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = apiKeyParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    const parsedBody = updateApiKeySchema.safeParse(req.body);
    if (!parsedBody.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedBody.error),
        }),
      );
      return;
    }

    try {
      const result = await this.updateApiKeyUseCase.execute(
        userId,
        parsedParams.data.id,
        parsedBody.data,
      );
      res.status(200).json(createSuccessResponse("Berhasil memperbarui nama API Key", result));
    } catch (error: any) {
      logger.error("ApiKeyController::updateKey() Error:", error);
      if (error instanceof NotFoundError) {
        res.status(404).json(createErrorResponse(error.message, null));
      } else {
        res.status(500).json(createErrorResponse(error.message, null));
      }
    }
  };
}
