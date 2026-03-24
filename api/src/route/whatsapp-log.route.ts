import { Router } from "express";
import { WhatsappLogController } from "../controller/whatsapp-log.controller.js";
import { WhatsappLogService } from "../service/whatsapp-log.service.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
  getWhatsappLogsSummaryQuerySchema,
} from "../lib/schemas/whatsapp-log.schema.js";

const whatsappLogRouter: Router = Router();
const whatsappLogService = new WhatsappLogService();
const whatsappLogController = new WhatsappLogController(whatsappLogService);

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
    "Mengambil ringkasan statistik WhatsApp log (jumlah, berdasarkan device, tipe pesan, dll).",
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
