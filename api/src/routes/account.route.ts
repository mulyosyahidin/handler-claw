import { Router } from "express";
import { PrismaAccountRepository } from "../modules/finances/accounts/infrastructure/repositories/prisma-account.repository.js";
import { CreateAccountUseCase } from "../modules/finances/accounts/application/use-cases/create-account.use-case.js";
import { GetAccountsUseCase } from "../modules/finances/accounts/application/use-cases/get-accounts.use-case.js";
import { GetAccountDetailUseCase } from "../modules/finances/accounts/application/use-cases/get-account-detail.use-case.js";
import { UpdateAccountUseCase } from "../modules/finances/accounts/application/use-cases/update-account.use-case.js";
import { DeleteAccountUseCase } from "../modules/finances/accounts/application/use-cases/delete-account.use-case.js";
import { AccountController } from "../modules/finances/accounts/interface-adapters/controllers/account.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createAccountSchema,
  updateAccountSchema,
  getAccountsQuerySchema,
  accountParamsSchema,
} from "../modules/finances/accounts/infrastructure/models/account.schema.js";

const accountRouter: Router = Router();

// Dependency Injection
const accountRepository = new PrismaAccountRepository();
const createAccountUseCase = new CreateAccountUseCase(accountRepository);
const getAccountsUseCase = new GetAccountsUseCase(accountRepository);
const getAccountDetailUseCase = new GetAccountDetailUseCase(accountRepository);
const updateAccountUseCase = new UpdateAccountUseCase(accountRepository);
const deleteAccountUseCase = new DeleteAccountUseCase(accountRepository);

const accountController = new AccountController(
  accountRepository,
  createAccountUseCase,
  getAccountsUseCase,
  getAccountDetailUseCase,
  updateAccountUseCase,
  deleteAccountUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/finances/accounts",
  summary: "Create a new Account",
  description: "Membuat akun baru (misal: Bank Mandiri atau Kas Tunai) untuk manajemen keuangan.",
  tags: ["Finances - Accounts"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createAccountSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Akun berhasil dibuat" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/accounts",
  summary: "Get Accounts",
  description: "Mengambil daftar akun milik pengguna.",
  tags: ["Finances - Accounts"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getAccountsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/accounts/{id}",
  summary: "Get Account Detail",
  description: "Mengambil detail akun berdasarkan ID.",
  tags: ["Finances - Accounts"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountParamsSchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    404: { description: "Akun tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/finances/accounts/{id}",
  summary: "Update Account",
  description: "Memperbarui data akun.",
  tags: ["Finances - Accounts"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: updateAccountSchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Berhasil diperbarui" },
    401: { description: "Unauthorized" },
    404: { description: "Akun tidak ditemukan" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "delete",
  path: "/api/finances/accounts/{id}",
  summary: "Delete Account",
  description: "Menghapus akun (soft delete).",
  tags: ["Finances - Accounts"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountParamsSchema,
  },
  responses: {
    200: { description: "Berhasil dihapus" },
    401: { description: "Unauthorized" },
    404: { description: "Akun tidak ditemukan" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

accountRouter.post("/", authMiddleware, accountController.create);
accountRouter.get("/", authMiddleware, accountController.getAll);
accountRouter.get("/:id", authMiddleware, accountController.getById);
accountRouter.patch("/:id", authMiddleware, accountController.update);
accountRouter.delete("/:id", authMiddleware, accountController.delete);

export default accountRouter;
