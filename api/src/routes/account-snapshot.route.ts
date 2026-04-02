import { Router } from "express";
import { PrismaAccountSnapshotRepository } from "../modules/(jwt-auth)/finances/account-snapshots/infrastructure/repositories/prisma-account-snapshot.repository.js";
import { PrismaAccountRepository } from "../modules/(jwt-auth)/finances/accounts/infrastructure/repositories/prisma-account.repository.js";
import { CreateAccountSnapshotUseCase } from "../modules/(jwt-auth)/finances/account-snapshots/application/use-cases/create-account-snapshot.use-case.js";
import { GetAccountSnapshotsUseCase } from "../modules/(jwt-auth)/finances/account-snapshots/application/use-cases/get-account-snapshots.use-case.js";
import { GetAccountSnapshotDetailUseCase } from "../modules/(jwt-auth)/finances/account-snapshots/application/use-cases/get-account-snapshot-detail.use-case.js";
import { UpdateAccountSnapshotUseCase } from "../modules/(jwt-auth)/finances/account-snapshots/application/use-cases/update-account-snapshot.use-case.js";
import { DeleteAccountSnapshotUseCase } from "../modules/(jwt-auth)/finances/account-snapshots/application/use-cases/delete-account-snapshot.use-case.js";
import { AccountSnapshotController } from "../modules/(jwt-auth)/finances/account-snapshots/interface-adapters/controllers/account-snapshot.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createAccountSnapshotSchema,
  updateAccountSnapshotSchema,
  getAccountSnapshotsQuerySchema,
  accountSnapshotParamsSchema,
} from "../modules/(jwt-auth)/finances/account-snapshots/infrastructure/models/account-snapshot.schema.js";

const accountSnapshotRouter: Router = Router();

// Dependency Injection
const accountSnapshotRepository = new PrismaAccountSnapshotRepository();
const accountRepository = new PrismaAccountRepository();

const createAccountSnapshotUseCase = new CreateAccountSnapshotUseCase(accountSnapshotRepository);
const getAccountSnapshotsUseCase = new GetAccountSnapshotsUseCase(accountSnapshotRepository);
const getAccountSnapshotDetailUseCase = new GetAccountSnapshotDetailUseCase(
  accountSnapshotRepository,
);
const updateAccountSnapshotUseCase = new UpdateAccountSnapshotUseCase(accountSnapshotRepository);
const deleteAccountSnapshotUseCase = new DeleteAccountSnapshotUseCase(accountSnapshotRepository);

const accountSnapshotController = new AccountSnapshotController(
  accountSnapshotRepository,
  accountRepository,
  createAccountSnapshotUseCase,
  getAccountSnapshotsUseCase,
  getAccountSnapshotDetailUseCase,
  updateAccountSnapshotUseCase,
  deleteAccountSnapshotUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/finances/account-snapshots",
  summary: "Create a new Account Snapshot",
  description: "Membuat catatan saldo akun pada tanggal tertentu.",
  tags: ["Finances - Account Snapshots"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createAccountSnapshotSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Snapshot saldo berhasil dibuat" },
    401: { description: "Unauthorized" },
    404: { description: "Akun tidak ditemukan" },
    409: { description: "Snapshot sudah ada untuk tanggal ini" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/account-snapshots",
  summary: "Get Account Snapshots",
  description: "Mengambil daftar catatan saldo milik pengguna.",
  tags: ["Finances - Account Snapshots"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getAccountSnapshotsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/account-snapshots/{id}",
  summary: "Get Account Snapshot Detail",
  description: "Mengambil detail catatan saldo berdasarkan ID.",
  tags: ["Finances - Account Snapshots"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountSnapshotParamsSchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    404: { description: "Snapshot saldo tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/finances/account-snapshots/{id}",
  summary: "Update Account Snapshot",
  description: "Memperbarui data catatan saldo.",
  tags: ["Finances - Account Snapshots"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountSnapshotParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: updateAccountSnapshotSchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Berhasil diperbarui" },
    401: { description: "Unauthorized" },
    404: { description: "Snapshot saldo tidak ditemukan" },
    409: { description: "Snapshot sudah ada untuk tanggal tersebut" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "delete",
  path: "/api/finances/account-snapshots/{id}",
  summary: "Delete Account Snapshot",
  description: "Menghapus catatan saldo (soft delete).",
  tags: ["Finances - Account Snapshots"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountSnapshotParamsSchema,
  },
  responses: {
    200: { description: "Berhasil dihapus" },
    401: { description: "Unauthorized" },
    404: { description: "Snapshot saldo tidak ditemukan" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

accountSnapshotRouter.post("/", authMiddleware, accountSnapshotController.create);
accountSnapshotRouter.get("/", authMiddleware, accountSnapshotController.getAll);
accountSnapshotRouter.get("/:id", authMiddleware, accountSnapshotController.getById);
accountSnapshotRouter.patch("/:id", authMiddleware, accountSnapshotController.update);
accountSnapshotRouter.delete("/:id", authMiddleware, accountSnapshotController.delete);

export default accountSnapshotRouter;
