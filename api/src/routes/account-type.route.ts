import { Router } from "express";
import { PrismaAccountTypeRepository } from "../modules/finances/account-types/infrastructure/repositories/prisma-account-type.repository.js";
import { CreateAccountTypeUseCase } from "../modules/finances/account-types/application/use-cases/create-account-type.use-case.js";
import { GetAccountTypesUseCase } from "../modules/finances/account-types/application/use-cases/get-account-types.use-case.js";
import { GetAccountTypeDetailUseCase } from "../modules/finances/account-types/application/use-cases/get-account-type-detail.use-case.js";
import { UpdateAccountTypeUseCase } from "../modules/finances/account-types/application/use-cases/update-account-type.use-case.js";
import { DeleteAccountTypeUseCase } from "../modules/finances/account-types/application/use-cases/delete-account-type.use-case.js";
import { AccountTypeController } from "../modules/finances/account-types/interface-adapters/controllers/account-type.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createAccountTypeSchema,
  updateAccountTypeSchema,
  getAccountTypesQuerySchema,
  accountTypeParamsSchema,
} from "../modules/finances/account-types/infrastructure/models/account-type.schema.js";

const accountTypeRouter: Router = Router();

// Dependency Injection
const accountTypeRepository = new PrismaAccountTypeRepository();
const createAccountTypeUseCase = new CreateAccountTypeUseCase(accountTypeRepository);
const getAccountTypesUseCase = new GetAccountTypesUseCase(accountTypeRepository);
const getAccountTypeDetailUseCase = new GetAccountTypeDetailUseCase(accountTypeRepository);
const updateAccountTypeUseCase = new UpdateAccountTypeUseCase(accountTypeRepository);
const deleteAccountTypeUseCase = new DeleteAccountTypeUseCase(accountTypeRepository);

const accountTypeController = new AccountTypeController(
  accountTypeRepository,
  createAccountTypeUseCase,
  getAccountTypesUseCase,
  getAccountTypeDetailUseCase,
  updateAccountTypeUseCase,
  deleteAccountTypeUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/finances/account-types",
  summary: "Create a new Account Type",
  description: "Membuat tipe akun baru untuk manajemen keuangan.",
  tags: ["Finances - Account Types"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createAccountTypeSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Tipe akun berhasil dibuat" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/account-types",
  summary: "Get Account Types",
  description: "Mengambil daftar tipe akun milik pengguna.",
  tags: ["Finances - Account Types"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getAccountTypesQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/finances/account-types/{id}",
  summary: "Get Account Type Detail",
  description: "Mengambil detail tipe akun berdasarkan ID.",
  tags: ["Finances - Account Types"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountTypeParamsSchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    404: { description: "Tipe akun tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/finances/account-types/{id}",
  summary: "Update Account Type",
  description: "Memperbarui data tipe akun.",
  tags: ["Finances - Account Types"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountTypeParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: updateAccountTypeSchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Berhasil diperbarui" },
    401: { description: "Unauthorized" },
    404: { description: "Tipe akun tidak ditemukan" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "delete",
  path: "/api/finances/account-types/{id}",
  summary: "Delete Account Type",
  description: "Menghapus tipe akun (soft delete).",
  tags: ["Finances - Account Types"],
  security: [{ bearerAuth: [] }],
  request: {
    params: accountTypeParamsSchema,
  },
  responses: {
    200: { description: "Berhasil dihapus" },
    401: { description: "Unauthorized" },
    404: { description: "Tipe akun tidak ditemukan" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

accountTypeRouter.post("/", authMiddleware, accountTypeController.create);
accountTypeRouter.get("/", authMiddleware, accountTypeController.getAll);
accountTypeRouter.get("/:id", authMiddleware, accountTypeController.getById);
accountTypeRouter.patch("/:id", authMiddleware, accountTypeController.update);
accountTypeRouter.delete("/:id", authMiddleware, accountTypeController.delete);

export default accountTypeRouter;
