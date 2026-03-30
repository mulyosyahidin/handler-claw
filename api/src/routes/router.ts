import { Router } from "express";
import appRouter from "./app.route.js";
import authRouter from "./auth.route.js";
import prayerLogRouter from "./prayer-log.route.js";
import whatsappLogRouter from "./whatsapp-log.route.js";
import notificationRouter from "./notification.route.js";
import userDeviceRouter from "./user-device.route.js";
import overviewRouter from "./overview.route.js";
import fileRouter from "./file.route.js";
import apiKeyRouter from "./api-key.route.js";
import accountTypeRouter from "./account-type.route.js";

const router: Router = Router();

router.use("/", appRouter);
router.use("/auth", authRouter);
router.use("/prayer-logs", prayerLogRouter);
router.use("/whatsapp-logs", whatsappLogRouter);
router.use("/notifications", notificationRouter);
router.use("/user-devices", userDeviceRouter);
router.use("/overview", overviewRouter);
router.use("/files", fileRouter);
router.use("/api-keys", apiKeyRouter);
router.use("/finances/account-types", accountTypeRouter);

export default router;
