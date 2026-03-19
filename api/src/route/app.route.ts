import { Router } from "express";
import { AppController } from "@/controller/app.controller";
import { AppService } from "@/service/app.service";

const appRouter: Router = Router();

const appController = new AppController(new AppService());

appRouter.get("/", appController.welcome);
appRouter.get("/health-check", appController.healthCheck);

export default appRouter;
