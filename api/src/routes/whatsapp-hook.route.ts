import { Router } from "express";
import { WhatsappHookController } from "../modules/whatsapp-hooks/interface-adapters/whatsapp-hook.controller.js";
import { PrismaWhatsappLogRepository } from "../modules/_shared/whatsapp-hooks/infrastructure/repositories/prisma-whatsapp-hook.repository.js";
import { PrismaWhatsappMessageRepository } from "../modules/_shared/whatsapp-hooks/infrastructure/repositories/prisma-whatsapp-message.repository.js";
import { CreateWebhookLogUseCase } from "../modules/_shared/whatsapp-hooks/application/use-cases/create-webhook-log.use-case.js";
import { CreateWhatsappMessageUseCase } from "../modules/_shared/whatsapp-hooks/application/use-cases/create-whatsapp-message.use-case.js";
import { whatsappSignatureMiddleware } from "../middleware/index.js";
import { WebhookLoggerService } from "../modules/_shared/whatsapp-hooks/infrastructure/services/webhook-logger.service.js";

const whatsappHookRouter: Router = Router();

// Dependency Injection
const whatsappHookRepository = new PrismaWhatsappLogRepository();
const whatsappMessageRepository = new PrismaWhatsappMessageRepository();
const createWebhookLogUseCase = new CreateWebhookLogUseCase(whatsappHookRepository);
const createWhatsappMessageUseCase = new CreateWhatsappMessageUseCase(whatsappMessageRepository);
const webhookLogger = new WebhookLoggerService();

const whatsappHookController = new WhatsappHookController(
  createWebhookLogUseCase,
  createWhatsappMessageUseCase,
  webhookLogger,
);

whatsappHookRouter.post(
  "/incoming-message",
  whatsappSignatureMiddleware,
  whatsappHookController.handleIncomingMessage,
);

export default whatsappHookRouter;
