import { Router } from "express";
import { AuthController } from "../modules/auth/interface-adapters/controllers/auth.controller.js";
import { PrismaUserRepository } from "../modules/auth/infrastructure/repositories/prisma-user.repository.js";
import { BcryptPasswordService } from "../modules/auth/infrastructure/services/bcrypt-password.service.js";
import { JoseTokenService } from "../modules/auth/infrastructure/services/jose-token.service.js";
import { LoginUseCase } from "../modules/auth/application/use-cases/login.use-case.js";
import { RefreshTokenUseCase } from "../modules/auth/application/use-cases/refresh-token.use-case.js";
import { GetMeUseCase } from "../modules/auth/application/use-cases/get-me.use-case.js";
import { UpdateProfileUseCase } from "../modules/auth/application/use-cases/update-profile.use-case.js";
import { UpdatePasswordUseCase } from "../modules/auth/application/use-cases/update-password.use-case.js";
import { GoogleLoginUseCase } from "../modules/auth/application/use-cases/google-login.use-case.js";
import { UpdateAvatarUseCase } from "../modules/auth/application/use-cases/update-avatar.use-case.js";
import { PrismaFileRepository } from "../modules/files/infrastructure/repositories/prisma-file.repository.js";
import { PrismaUserDeviceRepository } from "../modules/user-device/infrastructure/repositories/prisma-user-device.repository.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";

const authRouter: Router = Router();

// Infrastructure Layer
const userRepository = new PrismaUserRepository();
const passwordService = new BcryptPasswordService();
const tokenService = new JoseTokenService();
const fileRepository = new PrismaFileRepository();
const userDeviceRepository = new PrismaUserDeviceRepository();

// Application Layer (Use Cases)
const loginUseCase = new LoginUseCase(userRepository, passwordService, tokenService);
const refreshTokenUseCase = new RefreshTokenUseCase(tokenService);
const getMeUseCase = new GetMeUseCase(userRepository);
const updateProfileUseCase = new UpdateProfileUseCase(userRepository);
const updatePasswordUseCase = new UpdatePasswordUseCase(userRepository, passwordService);
const googleLoginUseCase = new GoogleLoginUseCase(
  userRepository,
  tokenService,
  fileRepository,
  userDeviceRepository,
);
const updateAvatarUseCase = new UpdateAvatarUseCase(userRepository);

// Interface Adapters Layer (Controller)
const authController = new AuthController(
  loginUseCase,
  refreshTokenUseCase,
  getMeUseCase,
  updateProfileUseCase,
  updatePasswordUseCase,
  googleLoginUseCase,
  updateAvatarUseCase,
);

registry.registerPath({
  method: "post",
  path: "/api/auth/google",
  summary: "Login with Google",
  description: "Melakukan login atau registrasi menggunakan Firebase ID Token dari Google.",
  tags: ["Auth"],
  responses: {
    200: { description: "Berhasil login dengan Google" },
    401: { description: "Token tidak valid" },
  },
});

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

registry.registerPath({
  method: "patch",
  path: "/api/auth/profile/avatar",
  summary: "Update Avatar",
  description: "Memperbarui URL foto profil (avatar) pengguna yang sedang login.",
  tags: ["Auth"],
  security: [{ bearerAuth: [] }],
  responses: {
    200: { description: "Avatar berhasil diperbarui" },
    400: { description: "Validasi gagal" },
    401: { description: "Unauthorized" },
  },
});

authRouter.post("/login", authController.login);
authRouter.post("/google", authController.googleLogin);
authRouter.post("/refresh-access-token", authController.refreshToken);
authRouter.get("/profile", authMiddleware, authController.getMe);
authRouter.patch("/profile", authMiddleware, authController.updateProfile);
authRouter.patch("/profile/password", authMiddleware, authController.updatePassword);
authRouter.patch("/profile/avatar", authMiddleware, authController.updateAvatar);

export default authRouter;
