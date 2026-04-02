import { Router } from "express";
import { PrismaWhatsappLogRepository } from "../modules/_shared/whatsapp-logs/infrastructure/repositories/prisma-whatsapp-log.repository.js";
import { GetWhatsappLogsUseCase } from "../modules/_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs.use-case.js";
import { GetWhatsappLogsSummaryUseCase } from "../modules/_shared/whatsapp-logs/application/use-cases/get-whatsapp-logs-summary.use-case.js";
import { AppWhatsappLogController } from "../modules/(api-key-auth)/whatsapp-logs/interface-adapters/controllers/whatsapp-log.controller.js";
import { apiKeyMiddleware } from "../middleware/api-key.middleware.js";
import { registry } from "../lib/openapi-registry.js";
import {
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../modules/_shared/whatsapp-logs/infrastructure/models/whatsapp-log.schema.js";

const appWhatsappLogRouter: Router = Router();

// Dependency Injection
const whatsappLogRepository = new PrismaWhatsappLogRepository();
const getWhatsappLogsUseCase = new GetWhatsappLogsUseCase(whatsappLogRepository);
const getWhatsappLogsSummaryUseCase = new GetWhatsappLogsSummaryUseCase(whatsappLogRepository);
const appWhatsappLogController = new AppWhatsappLogController(
  getWhatsappLogsUseCase,
  getWhatsappLogsSummaryUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "get",
  path: "/api/app/whatsapp-logs",
  summary: "Get WhatsApp logs via App",
  description: "Mengambil daftar WhatsApp log dengan offset-based pagination menggunakan API Key.",
  tags: ["App WhatsApp Logs"],
  security: [{ apiKeyAuth: [] }],
  request: {
    query: getWhatsappLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/app/whatsapp-logs/summary",
  summary: "Get WhatsApp logs summary via App",
  description: "Mengambil ringkasan WhatsApp log menggunakan API Key.",
  tags: ["App WhatsApp Logs"],
  security: [{ apiKeyAuth: [] }],
  request: {
    query: getWhatsappLogsSummaryQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

appWhatsappLogRouter.use(apiKeyMiddleware);

appWhatsappLogRouter.get("/", appWhatsappLogController.getLogs);
appWhatsappLogRouter.get("/summary", appWhatsappLogController.getSummary);

export default appWhatsappLogRouter;
