import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import {
  createAccountSchema,
  updateAccountSchema,
  getAccountsQuerySchema,
  accountParamsSchema,
} from "../../infrastructure/models/account.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";
import type { CreateAccountUseCase } from "../../application/use-cases/create-account.use-case.js";
import type { GetAccountsUseCase } from "../../application/use-cases/get-accounts.use-case.js";
import type { GetAccountDetailUseCase } from "../../application/use-cases/get-account-detail.use-case.js";
import type { UpdateAccountUseCase } from "../../application/use-cases/update-account.use-case.js";
import type { DeleteAccountUseCase } from "../../application/use-cases/delete-account.use-case.js";

export class AccountController {
  constructor(
    private accountRepository: AccountRepository,
    private createAccountUseCase: CreateAccountUseCase,
    private getAccountsUseCase: GetAccountsUseCase,
    private getAccountDetailUseCase: GetAccountDetailUseCase,
    private updateAccountUseCase: UpdateAccountUseCase,
    private deleteAccountUseCase: DeleteAccountUseCase,
  ) {}

  // POST /api/finances/accounts
  create = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createAccountSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(422).json(createErrorResponse("Validation error", zodErrorMapper(parsed.error)));
      return;
    }

    try {
      const existing = await this.accountRepository.findByNameAndType(
        userId,
        parsed.data.name,
        parsed.data.account_type_id,
      );
      if (existing) {
        res.status(409).json(
          createErrorResponse("Nama akun sudah digunakan", {
            name: "Nama ini sudah ada, silakan gunakan nama lain",
          }),
        );
        return;
      }

      const result = await this.createAccountUseCase.execute(userId, parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil membuat akun", result));
    } catch (error: any) {
      logger.error("AccountController::create() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/accounts
  getAll = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getAccountsQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      res.status(422).json(createErrorResponse("Validation error", zodErrorMapper(parsed.error)));
      return;
    }

    try {
      const result = await this.getAccountsUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar akun", result));
    } catch (error: any) {
      logger.error("AccountController::getAll() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/accounts/:id
  getById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)));
      return;
    }

    try {
      const account = await this.accountRepository.findById(userId, parsedParams.data.id);
      if (!account) {
        res.status(404).json(createErrorResponse("Akun tidak ditemukan", null));
        return;
      }

      const result = await this.getAccountDetailUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil mengambil detail akun", result));
    } catch (error: any) {
      logger.error("AccountController::getById() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // PATCH /api/finances/accounts/:id
  update = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)));
      return;
    }

    const parsedBody = updateAccountSchema.safeParse(req.body);
    if (!parsedBody.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedBody.error)));
      return;
    }

    try {
      const account = await this.accountRepository.findById(userId, parsedParams.data.id);
      if (!account) {
        res.status(404).json(createErrorResponse("Akun tidak ditemukan", null));
        return;
      }

      if (parsedBody.data.name !== undefined) {
        const existing = await this.accountRepository.findByNameAndType(
          userId,
          parsedBody.data.name,
          parsedBody.data.account_type_id ?? account.accountTypeId,
        );
        if (existing && existing.id !== parsedParams.data.id) {
          res.status(409).json(
            createErrorResponse("Nama akun sudah digunakan", {
              name: "Nama ini sudah ada, silakan gunakan nama lain",
            }),
          );
          return;
        }
      }

      const result = await this.updateAccountUseCase.execute(
        userId,
        parsedParams.data.id,
        parsedBody.data,
      );
      res.status(200).json(createSuccessResponse("Berhasil memperbarui akun", result));
    } catch (error: any) {
      logger.error("AccountController::update() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // DELETE /api/finances/accounts/:id
  delete = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res
        .status(422)
        .json(createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)));
      return;
    }

    try {
      const account = await this.accountRepository.findById(userId, parsedParams.data.id);
      if (!account) {
        res.status(404).json(createErrorResponse("Akun tidak ditemukan", null));
        return;
      }

      await this.deleteAccountUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil menghapus akun"));
    } catch (error: any) {
      logger.error("AccountController::delete() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
