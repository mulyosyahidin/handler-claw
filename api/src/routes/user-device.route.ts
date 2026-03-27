import { Router } from "express";
import { PrismaUserDeviceRepository } from "../modules/user-device/infrastructure/repositories/prisma-user-device.repository.js";
import { RegisterUserDeviceUseCase } from "../modules/user-device/application/use-cases/register-user-device.use-case.js";
import { GetUserDevicesUseCase } from "../modules/user-device/application/use-cases/get-user-devices.use-case.js";
import { GetUserDeviceDetailUseCase } from "../modules/user-device/application/use-cases/get-user-device-detail.use-case.js";
import { UpdateUserDeviceStatusUseCase } from "../modules/user-device/application/use-cases/update-user-device-status.use-case.js";
import { UserDeviceController } from "../modules/user-device/interface-adapters/controllers/user-device.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createUserDeviceSchema,
  updateUserDeviceStatusSchema,
  getUserDevicesQuerySchema,
  getUserDeviceParamsSchema,
} from "../modules/user-device/infrastructure/models/user-device.schema.js";

const userDeviceRouter: Router = Router();

// Dependency Injection
const userDeviceRepository = new PrismaUserDeviceRepository();
const registerUserDeviceUseCase = new RegisterUserDeviceUseCase(userDeviceRepository);
const getUserDevicesUseCase = new GetUserDevicesUseCase(userDeviceRepository);
const getDeviceDetailUseCase = new GetUserDeviceDetailUseCase(userDeviceRepository);
const updateDeviceStatusUseCase = new UpdateUserDeviceStatusUseCase(userDeviceRepository);

const userDeviceController = new UserDeviceController(
  registerUserDeviceUseCase,
  getUserDevicesUseCase,
  getDeviceDetailUseCase,
  updateDeviceStatusUseCase,
);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/user-devices",
  summary: "Register / Update a User Device",
  description:
    "Mendaftarkan perangkat pengguna untuk push notification. Jika device_id sudah ada, data akan di-update (upsert).",
  tags: ["User Devices"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createUserDeviceSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Perangkat berhasil didaftarkan" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/user-devices",
  summary: "Get User Devices (offset pagination)",
  description: "Mengambil daftar perangkat milik pengguna saat ini.",
  tags: ["User Devices"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getUserDevicesQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/user-devices/status",
  summary: "Update User Device Status",
  description: "Memperbarui status perangkat (misal: LOGGED_OUT, ACTIVE).",
  tags: ["User Devices"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: updateUserDeviceStatusSchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Status berhasil diperbarui" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/user-devices/{id}",
  summary: "Get User Device Detail",
  description: "Mengambil detail perangkat berdasarkan ID.",
  tags: ["User Devices"],
  security: [{ bearerAuth: [] }],
  request: {
    params: getUserDeviceParamsSchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    404: { description: "Device tidak ditemukan" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

userDeviceRouter.post("/", authMiddleware, userDeviceController.createDevice);
userDeviceRouter.patch("/status", authMiddleware, userDeviceController.updateDeviceStatus);
userDeviceRouter.get("/", authMiddleware, userDeviceController.getDevices);
userDeviceRouter.get("/:id", authMiddleware, userDeviceController.getDeviceById);

export default userDeviceRouter;
