import { Router } from "express";
import { PrismaHealthRepository } from "../modules/(jwt-auth)/system/infrastructure/repositories/prisma-health.repository.js";
import { HealthCheckUseCase } from "../modules/(jwt-auth)/system/application/use-cases/health-check.use-case.js";
import { SystemController } from "../modules/(jwt-auth)/system/interface-adapters/controllers/system.controller.js";

const appRouter: Router = Router();

// Dependency Injection
const healthRepository = new PrismaHealthRepository();
const healthCheckUseCase = new HealthCheckUseCase(healthRepository);
const systemController = new SystemController(healthCheckUseCase);

appRouter.get("/", systemController.welcome);
appRouter.get("/health-check", systemController.healthCheck);

export default appRouter;
