import { Router } from "express";
import { PrismaWhatsappMessageRepository } from "../modules/_shared/whatsapp-hooks/infrastructure/repositories/prisma-whatsapp-message.repository.js";
import { GetWhatsappMessagesUseCase } from "../modules/_shared/whatsapp-hooks/application/use-cases/get-whatsapp-messages.use-case.js";
import { WhatsappMessageController } from "../modules/whatsapp-hooks/interface-adapters/whatsapp-message.controller.js";
import { registry } from "../lib/openapi-registry.js";
import { getWhatsappMessagesQuerySchema } from "../modules/_shared/whatsapp-hooks/infrastructure/models/whatsapp-hook.schema.js";
import { authMiddleware } from "../middleware/auth.middleware.js";

const whatsappMessageRouter: Router = Router();

// Dependency Injection
const whatsappMessageRepository = new PrismaWhatsappMessageRepository();
const getWhatsappMessagesUseCase = new GetWhatsappMessagesUseCase(whatsappMessageRepository);
const whatsappMessageController = new WhatsappMessageController(getWhatsappMessagesUseCase);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "get",
  path: "/api/whatsapp-messages",
  summary: "Get WhatsApp messages",
  description: "Mengambil daftar pesan WhatsApp dengan pagination dan filter.",
  tags: ["WhatsApp Messages"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getWhatsappMessagesQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

whatsappMessageRouter.get("/", authMiddleware, whatsappMessageController.getMessages);

export default whatsappMessageRouter;
