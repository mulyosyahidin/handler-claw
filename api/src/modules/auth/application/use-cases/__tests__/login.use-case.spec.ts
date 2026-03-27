import { describe, it, expect, vi, beforeEach } from "vitest";
import { LoginUseCase } from "../login.use-case.js";
import type { UserRepository } from "../../../domain/repositories/user.repository.interface.js";
import type { PasswordService } from "../../../domain/services/password.service.interface.js";
import type { TokenService } from "../../../domain/services/token.service.interface.js";

describe("LoginUseCase", () => {
  let loginUseCase: LoginUseCase;
  let mockUserRepository: UserRepository;
  let mockPasswordService: PasswordService;
  let mockTokenService: TokenService;

  const mockUser = {
    id: "user-1",
    email: "test@example.com",
    name: "Test User",
    password: "hashedPassword",
    lastLoginAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(() => {
    mockUserRepository = {
      findByEmail: vi.fn(),
      findById: vi.fn(),
      updateLastLogin: vi.fn(),
      updateProfile: vi.fn(),
      updatePassword: vi.fn(),
      isEmailTaken: vi.fn(),
    } as unknown as UserRepository;

    mockPasswordService = {
      compare: vi.fn(),
      hash: vi.fn(),
    };

    mockTokenService = {
      createAccessToken: vi.fn(),
      refreshAccessToken: vi.fn(),
    };

    loginUseCase = new LoginUseCase(mockUserRepository, mockPasswordService, mockTokenService);
  });

  it("should login successfully with correct credentials", async () => {
    vi.mocked(mockUserRepository.findByEmail).mockResolvedValue(mockUser);
    vi.mocked(mockPasswordService.compare).mockResolvedValue(true);
    vi.mocked(mockTokenService.createAccessToken).mockResolvedValue("access-token");

    const result = await loginUseCase.execute({
      email: "test@example.com",
      password: "password123",
    });

    expect(result.access_token).toBe("access-token");
    expect(result.user.email).toBe("test@example.com");
    expect(mockUserRepository.updateLastLogin).toHaveBeenCalledWith("user-1");
  });

  it("should throw error if user is not found", async () => {
    vi.mocked(mockUserRepository.findByEmail).mockResolvedValue(null);

    await expect(
      loginUseCase.execute({
        email: "nonexistent@example.com",
        password: "password123",
      }),
    ).rejects.toEqual({
      message: "Periksa kembali kredensial Anda",
      errors: { email: "Email atau password salah" },
    });
  });

  it("should throw error if password is incorrect", async () => {
    vi.mocked(mockUserRepository.findByEmail).mockResolvedValue(mockUser);
    vi.mocked(mockPasswordService.compare).mockResolvedValue(false);

    await expect(
      loginUseCase.execute({
        email: "test@example.com",
        password: "wrongpassword",
      }),
    ).rejects.toEqual({
      message: "Periksa kembali kredensial Anda",
      errors: { password: "Email atau password salah" },
    });
  });
});
