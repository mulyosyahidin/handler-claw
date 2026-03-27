import { Router } from "express";
import { PrismaOverviewRepository } from "../modules/overview/infrastructure/repositories/prisma-overview.repository.js";
import { GetOverviewUseCase } from "../modules/overview/application/use-cases/get-overview.use-case.js";
import { OverviewController } from "../modules/overview/interface-adapters/controllers/overview.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";

const overviewRouter: Router = Router();

// Dependency Injection
const overviewRepository = new PrismaOverviewRepository();
const getOverviewUseCase = new GetOverviewUseCase(overviewRepository);
const overviewController = new OverviewController(getOverviewUseCase);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "get",
  path: "/api/overview",
  summary: "Get System Overview",
  description: "Mengambil ringkasan jumlah data (WhatsApp, Solat, Device, Hook) milik user.",
  tags: ["Overview"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Berhasil mengambil overview" },
    401: { description: "Unauthorized" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

overviewRouter.get("/", authMiddleware, overviewController.getOverview);

export default overviewRouter;
