import { Router } from "express";
import { PrismaNotificationRepository } from "../modules/_shared/notifications/infrastructure/repositories/prisma-notification.repository.js";
import { PrismaUserDeviceRepository } from "../modules/(jwt-auth)/user-devices/infrastructure/repositories/prisma-user-device.repository.js";
import { FirebaseNotificationService } from "../modules/_shared/notifications/infrastructure/services/firebase-notification.service.js";
import { CreateNotificationWebhookUseCase } from "../modules/_shared/notifications/application/use-cases/create-notification-webhook.use-case.js";
import { SendNotificationUseCase } from "../modules/_shared/notifications/application/use-cases/send-notification.use-case.js";
import { GetNotificationsUseCase } from "../modules/_shared/notifications/application/use-cases/get-notifications.use-case.js";
import { GetNotificationDetailUseCase } from "../modules/_shared/notifications/application/use-cases/get-notification-detail.use-case.js";
import { NotificationController } from "../modules/(jwt-auth)/notifications/interface-adapters/controllers/notification.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import { createNotificationWebhookSchema } from "../modules/_shared/notifications/infrastructure/models/notification-webhook.schema.js";
import { PrismaNotificationWebhookRepository } from "../modules/_shared/notifications/infrastructure/repositories/prisma-notification-webhook.repository.js";
import {
  getNotificationParamsSchema,
  getNotificationsQuerySchema,
} from "../modules/_shared/notifications/infrastructure/models/notification.schema.js";

const notificationRouter: Router = Router();

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

const getNotificationsUseCase = new GetNotificationsUseCase(notificationRepository);
const getNotificationDetailUseCase = new GetNotificationDetailUseCase(notificationRepository);

const notificationController = new NotificationController(
  createNotificationWebhookUseCase,
  getNotificationsUseCase,
  getNotificationDetailUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/notifications",
  summary: "Create a new Notification Handled Hook",
  description:
    "Menyimpan webhook reminder baru (membutuhkan autentikasi). Jika event_id sudah ada, data akan di-update (upsert).",
  tags: ["Notifications"],
  security: [{ bearerAuth: [] }],
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
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/notifications",
  summary: "Get Notifications (offset pagination)",
  description: "Mengambil daftar notifikasi milik pengguna saat ini.",
  tags: ["Notifications"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getNotificationsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/notifications/summary",
  summary: "Get Notifications Summary",
  description:
    "Mengambil ringkasan statistik (jumlah berdasarkan status) dari notifikasi milik pengguna saat ini.",
  tags: ["Notifications"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Berhasil mengambil summary" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/notifications/{id}",
  summary: "Get Notification Details",
  description: "Mengambil detail lengkap dari satu notifikasi berdasarkan ID.",
  tags: ["Notifications"],
  security: [{ bearerAuth: [] }],
  request: {
    params: getNotificationParamsSchema,
  },
  responses: {
    200: { description: "Berhasil mengambil detail" },
    401: { description: "Unauthorized" },
    404: { description: "Notifikasi tidak ditemukan" },
    422: { description: "Validation error" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

notificationRouter.post("/", authMiddleware, notificationController.createNotificationWebhook);
notificationRouter.get("/:id", authMiddleware, notificationController.getNotificationDetails);
notificationRouter.get("/", authMiddleware, notificationController.getNotifications);

export default notificationRouter;
