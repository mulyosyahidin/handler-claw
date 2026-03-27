import { createAccessToken, refreshAccessToken } from "../../../../lib/jose.js";
import type { TokenService } from "../../domain/services/token.service.interface.js";

export class JoseTokenService implements TokenService {
  async createAccessToken(payload: { userId: string; email: string }): Promise<string> {
    return createAccessToken(payload);
  }

  async refreshAccessToken(oldToken: string): Promise<string> {
    return refreshAccessToken(oldToken);
  }
}
