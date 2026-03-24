import { Router } from "express";
import appRouter from "./app.route.js";
import authRouter from "./auth.route.js";
import prayerLogRouter from "./prayer-log.route.js";
import whatsappLogRouter from "./whatsapp-log.route.js";

const router: Router = Router();

router.use("/", appRouter);
router.use("/auth", authRouter);
router.use("/prayer-logs", prayerLogRouter);
router.use("/whatsapp-logs", whatsappLogRouter);

export default router;
