import { Router } from "express";
import { PrayerLogController } from "../controller/index.js";
import { PrayerLogService } from "../service/index.js";
import { authMiddleware } from "../middleware/index.js";

const prayerLogRouter: Router = Router();
const prayerLogService = new PrayerLogService();
const prayerLogController = new PrayerLogController(prayerLogService);

import { registry } from "../lib/openapi-registry.js";
import {
  getPrayerLogsQuerySchema,
  getPrayerLogsSummaryQuerySchema,
  logPrayerSchema,
} from "../lib/schemas/prayer-log.schema.js";

registry.registerPath({
  method: "post",
  path: "/api/prayer-logs",
  summary: "Create a new Prayer Log",
  description: "Menyimpan atau memperbarui data jurnal solat.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: logPrayerSchema,
        },
      },
    },
  },
  responses: {
    200: { description: "Prayer log berhasil disimpan/diupdate" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
    409: { description: "Conflict" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/prayer-logs",
  summary: "Get Prayer Logs",
  description: "Mengambil daftar jurnal solat.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getPrayerLogsQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/prayer-logs/summary",
  summary: "Get Prayer Logs Summary",
  description: "Mengambil ringkasan statistik jurnal solat.",
  tags: ["Prayer Logs"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getPrayerLogsSummaryQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

prayerLogRouter.post("/", authMiddleware, prayerLogController.insertLog);
prayerLogRouter.get("/", authMiddleware, prayerLogController.getLogs);
prayerLogRouter.get("/summary", authMiddleware, prayerLogController.getSummary);

export default prayerLogRouter;
