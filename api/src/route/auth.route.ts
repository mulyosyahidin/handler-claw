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
  path: "/api/auth/profile",
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

registry.registerPath({
  method: "patch",
  path: "/api/auth/profile",
  summary: "Update Profile",
  description: "Memperbarui data profil (nama dan email) pengguna yang sedang login.",
  tags: ["Auth"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Profil berhasil diperbarui" },
    400: { description: "Validasi gagal atau email sudah digunakan" },
    401: { description: "Unauthorized" },
  },
});

registry.registerPath({
  method: "patch",
  path: "/api/auth/profile/password",
  summary: "Update Password",
  description: "Memperbarui password pengguna yang sedang login.",
  tags: ["Auth"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Password berhasil diperbarui" },
    400: { description: "Validasi gagal atau password saat ini salah" },
    401: { description: "Unauthorized" },
  },
});

authRouter.post("/login", authController.login);
authRouter.post("/refresh-access-token", authController.refreshToken);
authRouter.get("/profile", authMiddleware, authController.getMe);
authRouter.patch("/profile", authMiddleware, authController.updateProfile);
authRouter.patch("/profile/password", authMiddleware, authController.updatePassword);

export default authRouter;
