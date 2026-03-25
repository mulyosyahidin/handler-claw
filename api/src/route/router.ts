import { Router } from "express";
import appRouter from "./app.route.js";
import authRouter from "./auth.route.js";
import prayerLogRouter from "./prayer-log.route.js";
import whatsappLogRouter from "./whatsapp-log.route.js";
import reminderHookRouter from "./reminder-hook.route.js";
import userDeviceRouter from "./user-device.route.js";

const router: Router = Router();

router.use("/", appRouter);
router.use("/auth", authRouter);
router.use("/prayer-logs", prayerLogRouter);
router.use("/whatsapp-logs", whatsappLogRouter);
router.use("/reminder-hooks", reminderHookRouter);
router.use("/user-devices", userDeviceRouter);

export default router;
