import { Router } from "express";
import { PrismaNotificationRepository } from "../modules/notification/infrastructure/repositories/prisma-notification.repository.js";
import { PrismaUserDeviceRepository } from "../modules/user-device/infrastructure/repositories/prisma-user-device.repository.js";
import { FirebaseNotificationService } from "../modules/notification/infrastructure/services/firebase-notification.service.js";
import { CreateNotificationHookUseCase } from "../modules/notification/application/use-cases/create-notification-hook.use-case.js";
import { SendNotificationUseCase } from "../modules/notification/application/use-cases/send-notification.use-case.js";
import { GetNotificationsUseCase } from "../modules/notification/application/use-cases/get-notifications.use-case.js";
import { GetNotificationDetailUseCase } from "../modules/notification/application/use-cases/get-notification-detail.use-case.js";
import { GetNotificationsSummaryUseCase } from "../modules/notification/application/use-cases/get-notifications-summary.use-case.js";
import { NotificationController } from "../modules/notification/interface-adapters/controllers/notification.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createNotificationSchema,
  getNotificationParamsSchema,
  getNotificationsQuerySchema,
} from "../modules/notification/infrastructure/models/notification.schema.js";

const notificationRouter: Router = Router();

// Dependency Injection
const notificationRepository = new PrismaNotificationRepository();
const userDeviceRepository = new PrismaUserDeviceRepository();
const notificationSender = new FirebaseNotificationService();

const sendNotificationUseCase = new SendNotificationUseCase(
  notificationRepository,
  userDeviceRepository,
  notificationSender,
);

const createNotificationHookUseCase = new CreateNotificationHookUseCase(
  notificationRepository,
  userDeviceRepository,
  sendNotificationUseCase,
);

const getNotificationsUseCase = new GetNotificationsUseCase(notificationRepository);
const getNotificationDetailUseCase = new GetNotificationDetailUseCase(notificationRepository);
const getNotificationsSummaryUseCase = new GetNotificationsSummaryUseCase(notificationRepository);

const notificationController = new NotificationController(
  createNotificationHookUseCase,
  getNotificationsUseCase,
  getNotificationDetailUseCase,
  getNotificationsSummaryUseCase,
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
          schema: createNotificationSchema,
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

notificationRouter.post("/", authMiddleware, notificationController.createHook);
notificationRouter.get("/summary", authMiddleware, notificationController.getNotificationsSummary);
notificationRouter.get("/:id", authMiddleware, notificationController.getNotificationDetails);
notificationRouter.get("/", authMiddleware, notificationController.getNotifications);

export default notificationRouter;
