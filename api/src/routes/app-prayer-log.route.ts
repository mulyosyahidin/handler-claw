import { Router } from "express";
import { PrismaPrayerLogRepository } from "../modules/_shared/prayer-logs/infrastructure/repositories/prisma-prayer-log.repository.js";
import { CreatePrayerLogUseCase } from "../modules/_shared/prayer-logs/application/use-cases/create-prayer-log.use-case.js";
import { GetPrayerLogsUseCase } from "../modules/_shared/prayer-logs/application/use-cases/get-prayer-logs.use-case.js";
import { GetPrayerLogsSummaryUseCase } from "../modules/_shared/prayer-logs/application/use-cases/get-prayer-logs-summary.use-case.js";
import { AppPrayerLogController } from "../modules/(api-key-auth)/prayer-logs/interface-adapters/controllers/prayer-log.controller.js";
import { apiKeyMiddleware } from "../middleware/api-key.middleware.js";
import { registry } from "../lib/openapi-registry.js";
import {
  insertLogPrayerSchema,
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
} from "../modules/_shared/prayer-logs/infrastructure/models/prayer-log.schema.js";

const appPrayerLogRouter: Router = Router();

// Dependency Injection
const prayerLogRepository = new PrismaPrayerLogRepository();

const createPrayerLogUseCase = new CreatePrayerLogUseCase(prayerLogRepository);
const getPrayerLogsUseCase = new GetPrayerLogsUseCase(prayerLogRepository);
const getPrayerLogsSummaryUseCase = new GetPrayerLogsSummaryUseCase(prayerLogRepository);

const appPrayerLogController = new AppPrayerLogController(
  createPrayerLogUseCase,
  getPrayerLogsUseCase,
  getPrayerLogsSummaryUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/app/prayer-logs",
  summary: "Create a new prayer log (App)",
  description: "Mencatat jurnal solat menggunakan header x-api-key.",
  tags: ["App: Prayer Logs"],
  security: [{ apiKeyAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: insertLogPrayerSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Created successfully" },
    401: { description: "API Key Unauthorized" },
    409: { description: "Conflict" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/app/prayer-logs",
  summary: "Get Prayer Logs (App)",
  description: "Mengambil daftar jurnal solat menggunakan header x-api-key.",
  tags: ["App: Prayer Logs"],
  security: [{ apiKeyAuth: [] }],
  request: {
    query: getPrayerLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "API Key Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/app/prayer-logs/summary",
  summary: "Get Prayer Logs Summary (App)",
  description: "Mengambil ringkasan statistik jurnal solat menggunakan header x-api-key.",
  tags: ["App: Prayer Logs"],
  security: [{ apiKeyAuth: [] }],
  request: {
    query: getPrayerLogsSummaryQuerySchema,
  },
  responses: {
    200: { description: "Berhasil mengambil summary" },
    401: { description: "API Key Unauthorized" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

appPrayerLogRouter.get("/summary", apiKeyMiddleware, appPrayerLogController.getSummary);
appPrayerLogRouter.get("/", apiKeyMiddleware, appPrayerLogController.getLogs);
appPrayerLogRouter.post("/", apiKeyMiddleware, appPrayerLogController.insertLog);

export default appPrayerLogRouter;
