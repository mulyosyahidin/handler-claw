import { Router } from "express";
import { GetFinanceOverviewUseCase } from "../modules/finances/overview/application/use-cases/get-finance-overview.use-case.js";
import { FinanceOverviewController } from "../modules/finances/overview/interface-adapters/controllers/finance-overview.controller.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";
import { z } from "zod";

const financeOverviewRouter: Router = Router();

// Dependency Injection
const getFinanceOverviewUseCase = new GetFinanceOverviewUseCase();
const financeOverviewController = new FinanceOverviewController(getFinanceOverviewUseCase);

// ─── OPENAPI DOCS ──────────────────────────────────────────────────────────

registry.registerPath({
  method: "get",
  path: "/api/finances/overview",
  summary: "Get Finance Overview",
  description:
    "Mengambil daftar rekening, tipe akun, dan saldo terakhir dengan logika Carry Forward.",
  tags: ["Finances - Overview"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: {
      description: "Berhasil mengambil overview",
      content: {
        "application/json": {
          schema: z.object({
            success: z.boolean(),
            message: z.string(),
            data: z.object({
              account_types: z.array(
                z.object({
                  id: z.string(),
                  name: z.string(),
                  category: z.string(),
                  current_total_amount: z.number(),
                }),
              ),
              accounts: z.array(
                z.object({
                  id: z.string(),
                  name: z.string(),
                  current_amount: z.number(),
                  snapshots: z.array(z.any()),
                }),
              ),
              categories: z.object({
                liquid: z.number(),
                debt: z.number(),
                investment: z.number(),
              }),
              allocation: z.object({
                liquid_pct: z.number(),
                debt_pct: z.number(),
                investment_pct: z.number(),
              }),
              ratios: z.object({
                debt_to_asset_ratio: z.number(),
              }),
              top_movers: z.array(
                z.object({
                  id: z.string(),
                  name: z.string(),
                  amount_change: z.number(),
                  percentage_change: z.number(),
                  direction: z.enum(["UP", "DOWN", "STABLE"]),
                }),
              ),
              total_net_worth: z.number(),
            }),
          }),
        },
      },
    },
    401: { description: "Unauthorized" },
  },
});

// ─── ROUTES ────────────────────────────────────────────────────────────────

financeOverviewRouter.get("/", authMiddleware, financeOverviewController.getOverview);

export default financeOverviewRouter;
