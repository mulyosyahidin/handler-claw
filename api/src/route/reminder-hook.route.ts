import { Router } from "express";
import { ReminderHookController } from "../controller/reminder-hook.controller.js";
import { reminderHookService } from "../service/reminder-hook.service.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import {
  createReminderHookSchema,
  getReminderHooksQuerySchema,
} from "../lib/schemas/reminder-hook.schema.js";

const reminderHookRouter: Router = Router();
const reminderHookController = new ReminderHookController(reminderHookService);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "post",
  path: "/api/reminder-hooks",
  summary: "Create a new Reminder Hook",
  description:
    "Menyimpan webhook reminder baru (membutuhkan autentikasi). Jika event_id sudah ada, data akan di-update (upsert).",
  tags: ["Reminder Hooks"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: createReminderHookSchema,
        },
      },
    },
  },
  responses: {
    201: { description: "Reminder hook berhasil disimpan" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/reminder-hooks",
  summary: "Get Reminder Hooks (offset pagination)",
  description: "Mengambil daftar reminder hook milik pengguna saat ini.",
  tags: ["Reminder Hooks"],
  security: [{ bearerAuth: [] }],
  request: {
    query: getReminderHooksQuerySchema,
  },
  responses: {
    200: { description: "Berhasil" },
    401: { description: "Unauthorized" },
    422: { description: "Validation error" },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/reminder-hooks/summary",
  summary: "Get Reminder Hooks Summary",
  description:
    "Mengambil ringkasan statistik (jumlah berdasarkan status) dari reminder hooks milik pengguna saat ini.",
  tags: ["Reminder Hooks"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Berhasil mengambil summary" },
    401: { description: "Unauthorized" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

reminderHookRouter.post("/", authMiddleware, reminderHookController.createHook);
reminderHookRouter.get("/summary", authMiddleware, reminderHookController.getHooksSummary);
reminderHookRouter.get("/", authMiddleware, reminderHookController.getHooks);

export default reminderHookRouter;
