import { Router } from "express";
import appRouter from "./app.route";

const router: Router = Router();

router.use("/", appRouter);

export default router;
