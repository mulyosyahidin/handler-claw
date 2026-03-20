import { Router } from "express";
import { AppController } from "../controller/index.js";
import { AppService } from "../service/index.js";

const appRouter: Router = Router();

const appController = new AppController(new AppService());

appRouter.get("/", appController.welcome);
appRouter.get("/health-check", appController.healthCheck);

export default appRouter;
