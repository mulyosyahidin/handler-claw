import type { TokenService } from "../../domain/services/token.service.interface.js";
import type { RefreshTokenResponse } from "../dtos/auth.dto.js";

export class RefreshTokenUseCase {
  constructor(private tokenService: TokenService) {}

  async execute(oldToken: string): Promise<RefreshTokenResponse> {
    try {
      const newToken = await this.tokenService.refreshAccessToken(oldToken);
      return { access_token: newToken };
    } catch {
      throw {
        message: "Gagal refresh token",
        errors: { token: "Token tidak valid atau tidak dapat diverifikasi" },
      };
    }
  }
}
