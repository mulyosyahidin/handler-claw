import { Router } from "express";
import { AuthController } from "../controller/index.js";
import { AuthService } from "../service/index.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";

const authRouter: Router = Router();
const authService = new AuthService();
const authController = new AuthController(authService);

registry.registerPath({
  method: "get",
  path: "/api/auth/me",
  summary: "Get Current User Profile",
  description: "Mengambil data profil pengguna yang sedang login.",
  tags: ["Auth"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Berhasil mengambil data profil" },
    401: { description: "Unauthorized" },
    404: { description: "User tidak ditemukan" },
  },
});

authRouter.post("/login", authController.login);
authRouter.post("/refresh-access-token", authController.refreshToken);
authRouter.get("/me", authMiddleware, authController.getMe);

export default authRouter;
