import { Router } from "express";
import { PrismaWhatsappLogRepository } from "../modules/whatsapp-log/infrastructure/repositories/prisma-whatsapp-log.repository.js";
import { CreateWhatsappLogUseCase } from "../modules/whatsapp-log/application/use-cases/create-whatsapp-log.use-case.js";
import { GetWhatsappLogsUseCase } from "../modules/whatsapp-log/application/use-cases/get-whatsapp-logs.use-case.js";
import { WhatsappLogController } from "../modules/whatsapp-log/interface-adapters/controllers/whatsapp-log.controller.js";
import { PrismaUserRepository } from "../modules/auth/infrastructure/repositories/prisma-user.repository.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createWhatsappLogSchema,
  getWhatsappLogsQuerySchema,
} from "../modules/whatsapp-log/infrastructure/models/whatsapp-log.schema.js";
import { authMiddleware } from "../middleware/auth.middleware.js";

const whatsappLogRouter: Router = Router();

// Dependency Injection
const whatsappLogRepository = new PrismaWhatsappLogRepository();
const userRepository = new PrismaUserRepository();
const createWhatsappLogUseCase = new CreateWhatsappLogUseCase(
  whatsappLogRepository,
  userRepository,
);
const getWhatsappLogsUseCase = new GetWhatsappLogsUseCase(whatsappLogRepository);
const whatsappLogController = new WhatsappLogController(
  createWhatsappLogUseCase,
  getWhatsappLogsUseCase,
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
  summary: "Get WhatsApp logs",
  description: "Mengambil daftar WhatsApp log dengan offset-based pagination.",
  tags: ["WhatsApp Logs"],
  request: {
    query: getWhatsappLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

whatsappLogRouter.post("/", whatsappLogController.createLog);
whatsappLogRouter.post("/:userId", whatsappLogController.createLog);
whatsappLogRouter.get("/", authMiddleware, whatsappLogController.getLogs);

export default whatsappLogRouter;
