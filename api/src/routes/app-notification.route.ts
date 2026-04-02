import { Router } from "express";
import { PrismaNotificationRepository } from "../modules/_shared/notifications/infrastructure/repositories/prisma-notification.repository.js";
import { PrismaUserDeviceRepository } from "../modules/(jwt-auth)/user-devices/infrastructure/repositories/prisma-user-device.repository.js";
import { FirebaseNotificationService } from "../modules/_shared/notifications/infrastructure/services/firebase-notification.service.js";
import { CreateNotificationWebhookUseCase } from "../modules/_shared/notifications/application/use-cases/create-notification-webhook.use-case.js";
import { SendNotificationUseCase } from "../modules/_shared/notifications/application/use-cases/send-notification.use-case.js";
import { AppNotificationController } from "../modules/(api-key-auth)/notifications/interface-adapters/controllers/notification.controller.js";
import { apiKeyMiddleware } from "../middleware/api-key.middleware.js";
import { registry } from "../lib/openapi-registry.js";
import { createNotificationWebhookSchema } from "../modules/_shared/notifications/infrastructure/models/notification-webhook.schema.js";
import { PrismaNotificationWebhookRepository } from "../modules/_shared/notifications/infrastructure/repositories/prisma-notification-webhook.repository.js";

const appNotificationRouter: Router = Router();

// Dependency Injection
const notificationWebhookRepository = new PrismaNotificationWebhookRepository();
const notificationRepository = new PrismaNotificationRepository();
const userDeviceRepository = new PrismaUserDeviceRepository();
const notificationSender = new FirebaseNotificationService();

const sendNotificationUseCase = new SendNotificationUseCase(
  notificationWebhookRepository,
  notificationRepository,
  userDeviceRepository,
  notificationSender,
);

const createNotificationWebhookUseCase = new CreateNotificationWebhookUseCase(
  notificationWebhookRepository,
  notificationRepository,
  userDeviceRepository,
  sendNotificationUseCase,
);

const appNotificationController = new AppNotificationController(createNotificationWebhookUseCase);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/app/notifications",
  summary: "Create a new Notification Handled Hook (App)",
  description:
    "Menyimpan webhook reminder baru (membutuhkan autentikasi API Key). Jika event_id sudah ada, data akan di-update (upsert).",
  tags: ["App: Notifications"],
  security: [{ apiKeyAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createNotificationWebhookSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Notifikasi berhasil diproses" },
    401: { description: "API Key Unauthorized" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

appNotificationRouter.post(
  "/",
  apiKeyMiddleware,
  appNotificationController.createNotificationWebhook,
);

export default appNotificationRouter;
