import { Router } from "express";
import { PrismaPrayerLogRepository } from "../modules/prayer-log/infrastructure/repositories/prisma-prayer-log.repository.js";
import { CreatePrayerLogUseCase } from "../modules/prayer-log/application/use-cases/create-prayer-log.use-case.js";
import { GetPrayerLogsUseCase } from "../modules/prayer-log/application/use-cases/get-prayer-logs.use-case.js";
import { GetPrayerLogsSummaryUseCase } from "../modules/prayer-log/application/use-cases/get-prayer-logs-summary.use-case.js";
import { PrayerLogController } from "../modules/prayer-log/interface-adapters/controllers/prayer-log.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
  insertLogPrayerSchema,
} from "../modules/prayer-log/infrastructure/models/prayer-log.schema.js";

const prayerLogRouter: Router = Router();

// Dependency Injection
const prayerLogRepository = new PrismaPrayerLogRepository();

const createPrayerLogUseCase = new CreatePrayerLogUseCase(prayerLogRepository);
const getPrayerLogsUseCase = new GetPrayerLogsUseCase(prayerLogRepository);
const getPrayerLogsSummaryUseCase = new GetPrayerLogsSummaryUseCase(prayerLogRepository);

const prayerLogController = new PrayerLogController(
  createPrayerLogUseCase,
  getPrayerLogsUseCase,
  getPrayerLogsSummaryUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/prayer-logs",
  summary: "Log a Prayer",
  description:
    "Mencatat jurnal solat (membutuhkan autentikasi). Jika sudah ada catatan pada hari yang sama untuk jenis solat yang sama, maka akan di-update.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
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
    201: { description: "Jurnal solat berhasil dicatat" },
    401: { description: "Unauthorized" },
    409: { description: "Conflict (e.g. Jumat vs Dzuhur)" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/prayer-logs",
  summary: "Get Prayer Logs (offset pagination)",
  description: "Mengambil daftar jurnal solat milik pengguna saat ini.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getPrayerLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/prayer-logs/summary",
  summary: "Get Prayer Logs Summary",
  description:
    "Mengambil ringkasan statistik (jumlah & persentase) dari jurnal solat milik pengguna saat ini.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getPrayerLogsSummaryQuerySchema,
  },
  responses: {
    200: { description: "Berhasil mengambil summary" },
    401: { description: "Unauthorized" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

prayerLogRouter.get("/summary", authMiddleware, prayerLogController.getSummary);
prayerLogRouter.get("/", authMiddleware, prayerLogController.getLogs);
prayerLogRouter.post("/", authMiddleware, prayerLogController.insertLog);

export default prayerLogRouter;
