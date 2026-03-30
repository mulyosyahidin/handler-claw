import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import {
  createAccountTypeSchema,
  updateAccountTypeSchema,
  getAccountTypesQuerySchema,
  accountTypeParamsSchema,
} from "../../infrastructure/models/account-type.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";
import type { CreateAccountTypeUseCase } from "../../application/use-cases/create-account-type.use-case.js";
import type { GetAccountTypesUseCase } from "../../application/use-cases/get-account-types.use-case.js";
import type { GetAccountTypeDetailUseCase } from "../../application/use-cases/get-account-type-detail.use-case.js";
import type { UpdateAccountTypeUseCase } from "../../application/use-cases/update-account-type.use-case.js";
import type { DeleteAccountTypeUseCase } from "../../application/use-cases/delete-account-type.use-case.js";

export class AccountTypeController {
  constructor(
    private accountTypeRepository: AccountTypeRepository,
    private createAccountTypeUseCase: CreateAccountTypeUseCase,
    private getAccountTypesUseCase: GetAccountTypesUseCase,
    private getAccountTypeDetailUseCase: GetAccountTypeDetailUseCase,
    private updateAccountTypeUseCase: UpdateAccountTypeUseCase,
    private deleteAccountTypeUseCase: DeleteAccountTypeUseCase,
  ) {}

  // POST /api/finances/account-types
  create = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createAccountTypeSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(422).json(createErrorResponse("Validation error", zodErrorMapper(parsed.error)));
      return;
    }

    try {
      const existing = await this.accountTypeRepository.findByName(userId, parsed.data.name);
      if (existing) {
        res.status(409).json(
          createErrorResponse("Nama tipe akun sudah digunakan", {
            name: "Nama ini sudah ada, silakan gunakan nama lain",
          }),
        );
        return;
      }

      const result = await this.createAccountTypeUseCase.execute(userId, parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil membuat tipe akun", result));
    } catch (error: any) {
      logger.error("AccountTypeController::create() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/account-types
  getAll = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getAccountTypesQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      res.status(422).json(createErrorResponse("Validation error", zodErrorMapper(parsed.error)));
      return;
    }

    try {
      const result = await this.getAccountTypesUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar tipe akun", result));
    } catch (error: any) {
      logger.error("AccountTypeController::getAll() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/account-types/:id
  getById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountTypeParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)));
      return;
    }

    try {
      const accountType = await this.accountTypeRepository.findById(userId, parsedParams.data.id);
      if (!accountType) {
        res.status(404).json(createErrorResponse("Tipe akun tidak ditemukan", null));
        return;
      }

      const result = await this.getAccountTypeDetailUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil mengambil detail tipe akun", result));
    } catch (error: any) {
      logger.error("AccountTypeController::getById() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // PATCH /api/finances/account-types/:id
  update = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountTypeParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    const parsedBody = updateAccountTypeSchema.safeParse(req.body);
    if (!parsedBody.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedBody.error)));
      return;
    }

    try {
      const accountType = await this.accountTypeRepository.findById(userId, parsedParams.data.id);
      if (!accountType) {
        res.status(404).json(createErrorResponse("Tipe akun tidak ditemukan", null));
        return;
      }

      if (parsedBody.data.name !== undefined) {
        const existing = await this.accountTypeRepository.findByName(userId, parsedBody.data.name);
        if (existing && existing.id !== parsedParams.data.id) {
          res.status(409).json(
            createErrorResponse("Nama tipe akun sudah digunakan", {
              name: "Nama ini sudah ada, silakan gunakan nama lain",
            }),
          );
          return;
        }
      }

      const result = await this.updateAccountTypeUseCase.execute(
        userId,
        parsedParams.data.id,
        parsedBody.data,
      );
      res.status(200).json(createSuccessResponse("Berhasil memperbarui tipe akun", result));
    } catch (error: any) {
      logger.error("AccountTypeController::update() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // DELETE /api/finances/account-types/:id
  delete = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountTypeParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)));
      return;
    }

    try {
      const accountType = await this.accountTypeRepository.findById(userId, parsedParams.data.id);
      if (!accountType) {
        res.status(404).json(createErrorResponse("Tipe akun tidak ditemukan", null));
        return;
      }

      await this.deleteAccountTypeUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil menghapus tipe akun"));
    } catch (error: any) {
      logger.error("AccountTypeController::delete() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
