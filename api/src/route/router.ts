import { Router } from "express";
import appRouter from "./app.route.js";
import authRouter from "./auth.route.js";

const router: Router = Router();

router.use("/", appRouter);
router.use("/auth", authRouter);

export default router;
