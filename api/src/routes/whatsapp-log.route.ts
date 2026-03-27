import { Router } from "express";
import { PrismaWhatsappLogRepository } from "../modules/whatsapp-log/infrastructure/repositories/prisma-whatsapp-log.repository.js";
import { CreateWhatsappLogUseCase } from "../modules/whatsapp-log/application/use-cases/create-whatsapp-log.use-case.js";
import { GetWhatsappLogsUseCase } from "../modules/whatsapp-log/application/use-cases/get-whatsapp-logs.use-case.js";
import { GetWhatsappLogsSummaryUseCase } from "../modules/whatsapp-log/application/use-cases/get-whatsapp-logs-summary.use-case.js";
import { WhatsappLogController } from "../modules/whatsapp-log/interface-adapters/controllers/whatsapp-log.controller.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../modules/whatsapp-log/infrastructure/models/whatsapp-log.schema.js";

const whatsappLogRouter: Router = Router();

// Dependency Injection
const whatsappLogRepository = new PrismaWhatsappLogRepository();
const createWhatsappLogUseCase = new CreateWhatsappLogUseCase(whatsappLogRepository);
const getWhatsappLogsUseCase = new GetWhatsappLogsUseCase(whatsappLogRepository);
const getWhatsappLogsSummaryUseCase = new GetWhatsappLogsSummaryUseCase(whatsappLogRepository);
const whatsappLogController = new WhatsappLogController(
  createWhatsappLogUseCase,
  getWhatsappLogsUseCase,
  getWhatsappLogsSummaryUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/whatsapp-logs",
  summary: "Create a new WhatsApp log",
  description: "Menyimpan satu entri log WhatsApp yang diterima dari webhook.",
  tags: ["WhatsApp Logs"],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createWhatsappLogSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Log berhasil disimpan" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/whatsapp-logs",
  summary: "Get WhatsApp logs (cursor-based pagination)",
  description:
    "Mengambil daftar WhatsApp log dengan cursor-based pagination. Gunakan `next_cursor` dari response sebagai nilai `cursor` pada request berikutnya.",
  tags: ["WhatsApp Logs"],
  request: {
    query: getWhatsappLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/whatsapp-logs/summary",
  summary: "Get WhatsApp logs summary",
  description:
    "Mengambil ringkasan statistik WhatsApp log (jumlah, berdasarkan device, tipe pesan, dll) serta daftar pesan yang dikelompokkan per hari dan per pengirim (di dalam field `messages`).",
  tags: ["WhatsApp Logs"],
  request: {
    query: getWhatsappLogsSummaryQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

whatsappLogRouter.post("/", whatsappLogController.createLog);
whatsappLogRouter.get("/summary", whatsappLogController.getSummary);
whatsappLogRouter.get("/", whatsappLogController.getLogs);

export default whatsappLogRouter;
