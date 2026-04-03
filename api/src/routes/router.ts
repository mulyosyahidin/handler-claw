import { Router } from "express";
import appRouter from "./app.route.js";
import authRouter from "./auth.route.js";
import prayerLogRouter from "./prayer-log.route.js";
import notificationRouter from "./notification.route.js";
import userDeviceRouter from "./user-device.route.js";
import overviewRouter from "./overview.route.js";
import fileRouter from "./file.route.js";
import apiKeyRouter from "./api-key.route.js";
import accountTypeRouter from "./account-type.route.js";
import accountRouter from "./account.route.js";
import accountSnapshotRouter from "./account-snapshot.route.js";
import financeOverviewRouter from "./finance-overview.route.js";
import appPrayerLogRouter from "./app-prayer-log.route.js";
import appNotificationRouter from "./app-notification.route.js";
import appFileRouter from "./app-file.route.js";
import whatsappHookRouter from "./whatsapp-hook.route.js";
import whatsappMessageRouter from "./whatsapp-message.route.js";

const router: Router = Router();

router.use("/", appRouter);
router.use("/auth", authRouter);
router.use("/prayer-logs", prayerLogRouter);
router.use("/whatsapp-messages", whatsappMessageRouter);
router.use("/notifications", notificationRouter);
router.use("/user-devices", userDeviceRouter);
router.use("/overview", overviewRouter);
router.use("/files", fileRouter);
router.use("/api-keys", apiKeyRouter);
router.use("/finances/account-types", accountTypeRouter);
router.use("/finances/accounts", accountRouter);
router.use("/finances/account-snapshots", accountSnapshotRouter);
router.use("/finances/overview", financeOverviewRouter);
router.use("/whatsapp-hooks", whatsappHookRouter);

router.use("/app/prayer-logs", appPrayerLogRouter);
router.use("/app/notifications", appNotificationRouter);
router.use("/app/files", appFileRouter);

export default router;
