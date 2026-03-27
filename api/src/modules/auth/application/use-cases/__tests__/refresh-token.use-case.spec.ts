import { describe, it, expect, vi, beforeEach } from "vitest";
import { RefreshTokenUseCase } from "../refresh-token.use-case.js";
import type { TokenService } from "../../../domain/services/token.service.interface.js";

describe("RefreshTokenUseCase", () => {
  let refreshTokenUseCase: RefreshTokenUseCase;
  let mockTokenService: TokenService;

  beforeEach(() => {
    mockTokenService = {
      createAccessToken: vi.fn(),
      refreshAccessToken: vi.fn(),
    };

    refreshTokenUseCase = new RefreshTokenUseCase(mockTokenService);
  });

  it("should refresh token successfully", async () => {
    vi.mocked(mockTokenService.refreshAccessToken).mockResolvedValue("new-access-token");

    const result = await refreshTokenUseCase.execute("old-refresh-token");

    expect(result.access_token).toBe("new-access-token");
  });

  it("should throw error if token is invalid", async () => {
    vi.mocked(mockTokenService.refreshAccessToken).mockRejectedValue(new Error("Invalid token"));

    await expect(refreshTokenUseCase.execute("invalid-token")).rejects.toEqual({
      message: "Gagal refresh token",
      errors: { token: "Token tidak valid atau tidak dapat diverifikasi" },
    });
  });
});
