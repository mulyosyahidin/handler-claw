import { Router } from "express";
import { PrismaApiKeyRepository } from "../modules/(jwt-auth)/api-keys/infrastructure/repositories/prisma-api-key.repository.js";
import { CreateApiKeyUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/create-api-key.use-case.js";
import { GetApiKeysUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/get-api-keys.use-case.js";
import { GetApiKeyDetailUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/get-api-key-detail.use-case.js";
import { DeleteApiKeyUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/delete-api-key.use-case.js";
import { RevokeApiKeyUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/revoke-api-key.use-case.js";
import { RotateApiKeyUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/rotate-api-key.use-case.js";
import { UpdateApiKeyUseCase } from "../modules/(jwt-auth)/api-keys/application/use-cases/update-api-key.use-case.js";
import { ApiKeyController } from "../modules/(jwt-auth)/api-keys/interface-adapters/controllers/api-key.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createApiKeySchema,
  updateApiKeySchema,
  getApiKeysQuerySchema,
  apiKeyParamsSchema,
} from "../modules/(jwt-auth)/api-keys/infrastructure/models/api-key.schema.js";

const apiKeyRouter: Router = Router();

// Dependency Injection
const apiKeyRepository = new PrismaApiKeyRepository();
const createApiKeyUseCase = new CreateApiKeyUseCase(apiKeyRepository);
const getApiKeysUseCase = new GetApiKeysUseCase(apiKeyRepository);
const getApiKeyDetailUseCase = new GetApiKeyDetailUseCase(apiKeyRepository);
const deleteApiKeyUseCase = new DeleteApiKeyUseCase(apiKeyRepository);
const revokeApiKeyUseCase = new RevokeApiKeyUseCase(apiKeyRepository);
const rotateApiKeyUseCase = new RotateApiKeyUseCase(apiKeyRepository);
const updateApiKeyUseCase = new UpdateApiKeyUseCase(apiKeyRepository);

const apiKeyController = new ApiKeyController(
  createApiKeyUseCase,
  getApiKeysUseCase,
  getApiKeyDetailUseCase,
  deleteApiKeyUseCase,
  revokeApiKeyUseCase,
  rotateApiKeyUseCase,
  updateApiKeyUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/api-keys",
  summary: "Create a new API Key",
  description: "Membuat API Key baru untuk pengguna. Plain key hanya akan ditampilkan sekali.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createApiKeySchema,
        },
      },
    },
  },
  responses: {
    201: { description: "API Key berhasil dibuat" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/api-keys",
  summary: "Get all API Keys",
  description: "Mengambil daftar API Key milik pengguna saat ini.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getApiKeysQuerySchema,
  },
  responses: {
    200: { description: "Success" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/api-keys/{id}",
  summary: "Get API Key Detail",
  description: "Mengambil detail API Key berdasarkan ID.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    params: apiKeyParamsSchema,
  },
  responses: {
    200: { description: "Success" },
    401: { description: "Unauthorized" },
    404: { description: "API Key tidak ditemukan" },
  },
});

registry.registerPath({
  method: "delete",
  path: "/api/api-keys/{id}",
  summary: "Delete API Key",
  description: "Menghapus API Key secara soft-delete.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    params: apiKeyParamsSchema,
  },
  responses: {
    200: { description: "Berhasil dihapus" },
    401: { description: "Unauthorized" },
    404: { description: "API Key tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/api-keys/{id}/revoke",
  summary: "Revoke API Key",
  description: "Me-revoke API Key sehingga tidak bisa digunakan.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    params: apiKeyParamsSchema,
  },
  responses: {
    200: { description: "Berhasil di-revoke" },
    401: { description: "Unauthorized" },
    404: { description: "API Key tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/api-keys/{id}/rotate",
  summary: "Rotate API Key",
  description: "Mengganti API Key lama dengan yang baru. Plain key baru akan ditampilkan sekali.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    params: apiKeyParamsSchema,
  },
  responses: {
    200: { description: "Berhasil di-rotate" },
    401: { description: "Unauthorized" },
    404: { description: "API Key tidak ditemukan" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/api-keys/{id}",
  summary: "Update API Key Name",
  description: "Memperbarui nama API Key.",
  tags: ["API Keys"],
  security: [{ bearerAuth: [] }],
  request: {
    params: apiKeyParamsSchema,
    body: {
      content: {
        "application/json": {
          schema: updateApiKeySchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Berhasil diperbarui" },
    401: { description: "Unauthorized" },
    404: { description: "API Key tidak ditemukan" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

apiKeyRouter.post("/", authMiddleware, apiKeyController.createKey);
apiKeyRouter.get("/", authMiddleware, apiKeyController.getKeys);
apiKeyRouter.get("/:id", authMiddleware, apiKeyController.getKeyById);
apiKeyRouter.patch("/:id", authMiddleware, apiKeyController.updateKey);
apiKeyRouter.delete("/:id", authMiddleware, apiKeyController.deleteKey);
apiKeyRouter.patch("/:id/revoke", authMiddleware, apiKeyController.revokeKey);
apiKeyRouter.patch("/:id/rotate", authMiddleware, apiKeyController.rotateKey);

export default apiKeyRouter;
