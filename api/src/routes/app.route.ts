import { Router } from "express";
import { PrismaHealthRepository } from "../modules/system/infrastructure/repositories/prisma-health.repository.js";
import { HealthCheckUseCase } from "../modules/system/application/use-cases/health-check.use-case.js";
import { SystemController } from "../modules/system/interface-adapters/controllers/system.controller.js";

const appRouter: Router = Router();

// Dependency Injection
const healthRepository = new PrismaHealthRepository();
const healthCheckUseCase = new HealthCheckUseCase(healthRepository);
const systemController = new SystemController(healthCheckUseCase);

appRouter.get("/", systemController.welcome);
appRouter.get("/health-check", systemController.healthCheck);

export default appRouter;
