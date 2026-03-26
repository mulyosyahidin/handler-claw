import { Router } from "express";
import { UserDeviceController } from "../controller/user-device.controller.js";
import { userDeviceService } from "../service/user-device.service.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createUserDeviceSchema,
  updateUserDeviceStatusSchema,
  getUserDevicesQuerySchema,
  getUserDeviceParamsSchema,
} from "../lib/schemas/user-device.schema.js";

const userDeviceRouter: Router = Router();
const userDeviceController = new UserDeviceController(userDeviceService);

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
