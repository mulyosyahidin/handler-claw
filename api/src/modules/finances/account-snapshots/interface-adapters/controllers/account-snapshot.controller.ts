import type { Response } from "express";
import type { AuthRequest } from "../../../../../middleware/auth.middleware.js";
import {
  createAccountSnapshotSchema,
  updateAccountSnapshotSchema,
  getAccountSnapshotsQuerySchema,
  accountSnapshotParamsSchema,
} from "../../infrastructure/models/account-snapshot.schema.js";
import { zodErrorMapper } from "../../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../../lib/types/response.js";
import logger from "../../../../../config/logger.js";
import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";
import type { AccountRepository } from "../../../accounts/domain/repositories/account.repository.interface.js";
import type { CreateAccountSnapshotUseCase } from "../../application/use-cases/create-account-snapshot.use-case.js";
import type { GetAccountSnapshotsUseCase } from "../../application/use-cases/get-account-snapshots.use-case.js";
import type { GetAccountSnapshotDetailUseCase } from "../../application/use-cases/get-account-snapshot-detail.use-case.js";
import type { UpdateAccountSnapshotUseCase } from "../../application/use-cases/update-account-snapshot.use-case.js";
import type { DeleteAccountSnapshotUseCase } from "../../application/use-cases/delete-account-snapshot.use-case.js";

export class AccountSnapshotController {
  constructor(
    private accountSnapshotRepository: AccountSnapshotRepository,
    private accountRepository: AccountRepository,
    private createAccountSnapshotUseCase: CreateAccountSnapshotUseCase,
    private getAccountSnapshotsUseCase: GetAccountSnapshotsUseCase,
    private getAccountSnapshotDetailUseCase: GetAccountSnapshotDetailUseCase,
    private updateAccountSnapshotUseCase: UpdateAccountSnapshotUseCase,
    private deleteAccountSnapshotUseCase: DeleteAccountSnapshotUseCase,
  ) {}

  // POST /api/finances/account-snapshots
  create = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createAccountSnapshotSchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsed.error)),
      );
      return;
    }

    try {
      // 1. Verify account ownership
      const account = await this.accountRepository.findById(userId, parsed.data.account_id);
      if (!account) {
        res.status(404).json(createErrorResponse("Akun tidak ditemukan", null));
        return;
      }

      // 2. Verify date uniqueness per account
      const existing = await this.accountSnapshotRepository.findByDate(
        parsed.data.account_id,
        parsed.data.date,
      );
      if (existing) {
        res.status(409).json(
          createErrorResponse("Snapshot sudah ada untuk tanggal ini", {
            date: "Satu akun hanya boleh memiliki satu snapshot per tanggal",
          }),
        );
        return;
      }

      const createData: any = {
        account_id: parsed.data.account_id,
        amount: parsed.data.amount,
        date: parsed.data.date,
      };
      if (parsed.data.note !== undefined) createData.note = parsed.data.note;

      const result = await this.createAccountSnapshotUseCase.execute(userId, createData);
      res.status(201).json(createSuccessResponse("Berhasil membuat snapshot saldo", result));
    } catch (error: any) {
      logger.error("AccountSnapshotController::create() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/account-snapshots
  getAll = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getAccountSnapshotsQuerySchema.safeParse(req.query);
    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsed.error)),
      );
      return;
    }

    try {
      const query: any = {
        page: parsed.data.page,
        per_page: parsed.data.per_page,
      };
      if (parsed.data.account_id !== undefined) query.account_id = parsed.data.account_id;
      if (parsed.data.start_date !== undefined) query.start_date = parsed.data.start_date;
      if (parsed.data.end_date !== undefined) query.end_date = parsed.data.end_date;

      const result = await this.getAccountSnapshotsUseCase.execute(userId, query);
      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar snapshot", result));
    } catch (error: any) {
      logger.error("AccountSnapshotController::getAll() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/finances/account-snapshots/:id
  getById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountSnapshotParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)),
      );
      return;
    }

    try {
      const snapshot = await this.accountSnapshotRepository.findById(userId, parsedParams.data.id);
      if (!snapshot) {
        res.status(404).json(createErrorResponse("Snapshot saldo tidak ditemukan", null));
        return;
      }

      const result = await this.getAccountSnapshotDetailUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil mengambil detail snapshot", result));
    } catch (error: any) {
      logger.error("AccountSnapshotController::getById() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // PATCH /api/finances/account-snapshots/:id
  update = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountSnapshotParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)),
      );
      return;
    }

    const parsedBody = updateAccountSnapshotSchema.safeParse(req.body);
    if (!parsedBody.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsedBody.error)),
      );
      return;
    }

    try {
      const snapshot = await this.accountSnapshotRepository.findById(userId, parsedParams.data.id);
      if (!snapshot) {
        res.status(404).json(createErrorResponse("Snapshot saldo tidak ditemukan", null));
        return;
      }

      if (parsedBody.data.date !== undefined) {
        const existing = await this.accountSnapshotRepository.findByDate(
          snapshot.accountId,
          parsedBody.data.date,
        );
        if (existing && existing.id !== parsedParams.data.id) {
          res.status(409).json(
            createErrorResponse("Snapshot sudah ada untuk tanggal tersebut", {
              date: "Silakan gunakan tanggal lain atau perbarui snapshot yang sudah ada",
            }),
          );
          return;
        }
      }

      const updateData: any = {};
      if (parsedBody.data.amount !== undefined) updateData.amount = parsedBody.data.amount;
      if (parsedBody.data.date !== undefined) updateData.date = parsedBody.data.date;
      if (parsedBody.data.note !== undefined) updateData.note = parsedBody.data.note;

      const result = await this.updateAccountSnapshotUseCase.execute(
        userId,
        parsedParams.data.id,
        updateData,
      );
      res.status(200).json(createSuccessResponse("Berhasil memperbarui snapshot saldo", result));
    } catch (error: any) {
      logger.error("AccountSnapshotController::update() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // DELETE /api/finances/account-snapshots/:id
  delete = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = accountSnapshotParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", zodErrorMapper(parsedParams.error)),
      );
      return;
    }

    try {
      const snapshot = await this.accountSnapshotRepository.findById(userId, parsedParams.data.id);
      if (!snapshot) {
        res.status(404).json(createErrorResponse("Snapshot saldo tidak ditemukan", null));
        return;
      }

      await this.deleteAccountSnapshotUseCase.execute(userId, parsedParams.data.id);
      res.status(200).json(createSuccessResponse("Berhasil menghapus snapshot saldo"));
    } catch (error: any) {
      logger.error("AccountSnapshotController::delete() Error:", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
