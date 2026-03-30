import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import type { TokenService } from "../../domain/services/token.service.interface.js";
import type { UserDeviceRepository } from "../../../user-device/domain/repositories/user-device.repository.interface.js";
import type { FileRepository } from "../../../files/domain/repositories/file.repository.interface.js";
import { downloadExternalImage } from "../../../../utils/file-storage.js";
import type { GoogleLoginRequest, LoginResponse } from "../dtos/auth.dto.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import { UnauthorizedError } from "../../../../lib/errors/unauthorized.error.js";
import { getFirebaseAdmin } from "../../../../lib/firebase-admin.js";
import logger from "../../../../config/logger.js";
import { sendEmailWithTemplate } from "../../../../lib/email/resend.js";

export class GoogleLoginUseCase {
  constructor(
    private userRepository: UserRepository,
    private tokenService: TokenService,
    private fileRepository: FileRepository,
    private userDeviceRepository: UserDeviceRepository,
  ) {}

  async execute(request: GoogleLoginRequest): Promise<LoginResponse> {
    const { id_token } = request;

    let decodedToken;
    try {
      const admin = getFirebaseAdmin();
      decodedToken = await admin.auth().verifyIdToken(id_token);
    } catch (error) {
      throw new UnauthorizedError("Token Google tidak valid", {
        token: "Sesi Google telah berakhir atau tidak valid",
      });
    }

    const { email, name, picture } = decodedToken;

    if (!email) {
      throw new UnauthorizedError("Email tidak ditemukan di akun Google", {
        email: "Email diperlukan untuk login",
      });
    }

    let avatarUrl: string | undefined = picture || undefined;

    // Download and save avatar locally if available
    if (picture) {
      try {
        const fileData = await downloadExternalImage(picture);
        await this.fileRepository.create({
          fileName: fileData.filename,
          fileType: fileData.mimetype,
          fileSize: fileData.size,
          filePath: fileData.filePath,
        });

        avatarUrl = fileData.filePath;
      } catch (error) {
        logger.error("GoogleLoginUseCase::execute() Image download error:", error);

        avatarUrl = "https://i.pravatar.cc/300";
      }
    }

    let user = await this.userRepository.findByEmail(email);

    if (!user) {
      // Register new user
      user = await this.userRepository.create({
        email,
        name: name || email.split("@")[0],
        driver: "GOOGLE",
        avatarUrl,
      });

      // Send welcome email (non-blocking)
      sendEmailWithTemplate({
        to: user.email,
        subject: "Selamat Datang di HandlerClaw!",
        template: "welcome",
        context: {
          name: user.name,
          appUrl: process.env.APP_URL || "https://handlerclaw.com",
        },
      }).catch((err) => {
        logger.error("GoogleLoginUseCase::execute() Welcome email error:", err);
      });
    } else {
      // Update existing user info
      await this.userRepository.update(user.id, {
        lastLoginAt: new Date(),
        avatarUrl: avatarUrl || user.avatarUrl || undefined,
      });
    }

    const token = await this.tokenService.createAccessToken({
      userId: user.id,
      email: user.email,
    });

    // Register/update device if provided
    if (request.device_id && request.platform && request.fcm_token) {
      try {
        await this.userDeviceRepository.upsert(user.id, {
          deviceId: request.device_id,
          fcmToken: request.fcm_token,
          deviceBrand: request.device_brand ?? null,
          deviceModel: request.device_model ?? null,
          osBuildId: request.os_build_id ?? null,
          osVersion: request.os_version ?? null,
          platform: request.platform,
        });
      } catch (error) {
        console.error("GoogleLoginUseCase::execute() Device registration error:", error);
        // We don't throw here to avoid blocking login if device registration fails
      }
    }

    return {
      user: toUserEntity(user),
      access_token: token,
    };
  }
}
