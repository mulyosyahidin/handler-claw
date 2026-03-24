import { Router } from "express";
import { PrayerLogController } from "../controller/index.js";
import { PrayerLogService } from "../service/index.js";
import { authMiddleware } from "../middleware/index.js";

const prayerLogRouter: Router = Router();
const prayerLogService = new PrayerLogService();
const prayerLogController = new PrayerLogController(prayerLogService);

prayerLogRouter.post("/", authMiddleware, prayerLogController.insertLog);
prayerLogRouter.get("/", authMiddleware, prayerLogController.getLogs);
prayerLogRouter.get("/summary", authMiddleware, prayerLogController.getSummary);

export default prayerLogRouter;
