import { Router } from "express";
import { AuthController } from "../controller/index.js";
import { AuthService } from "../service/index.js";

const authRouter: Router = Router();
const authService = new AuthService();
const authController = new AuthController(authService);

authRouter.post("/login", authController.login);

export default authRouter;
