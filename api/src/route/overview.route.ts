import { Router } from "express";
import { OverviewController } from "../controller/overview.controller.js";
import { overviewService } from "../service/overview.service.js";
import { authMiddleware } from "../middleware/auth.middleware.js";

const overviewRouter: Router = Router();
const overviewController = new OverviewController(overviewService);

overviewRouter.get("/", authMiddleware, overviewController.getOverview);

export default overviewRouter;
