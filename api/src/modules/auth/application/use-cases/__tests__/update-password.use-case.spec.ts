import { describe, it, expect, vi, beforeEach } from "vitest";
import { UpdatePasswordUseCase } from "../update-password.use-case.js";
import type { UserRepository } from "../../../domain/repositories/user.repository.interface.js";
import type { PasswordService } from "../../../domain/services/password.service.interface.js";

describe("UpdatePasswordUseCase", () => {
  let updatePasswordUseCase: UpdatePasswordUseCase;
  let mockUserRepository: UserRepository;
  let mockPasswordService: PasswordService;

  const mockUser = {
    id: "user-1",
    password: "oldHashedPassword",
  };

  beforeEach(() => {
    mockUserRepository = {
      findById: vi.fn(),
      updatePassword: vi.fn(),
    } as unknown as UserRepository;

    mockPasswordService = {
      compare: vi.fn(),
      hash: vi.fn(),
    };

    updatePasswordUseCase = new UpdatePasswordUseCase(mockUserRepository, mockPasswordService);
  });

  it("should update password successfully", async () => {
    vi.mocked(mockUserRepository.findById).mockResolvedValue(mockUser as any);
    vi.mocked(mockPasswordService.compare).mockResolvedValue(true);
    vi.mocked(mockPasswordService.hash).mockResolvedValue("newHashedPassword");

    const result = await updatePasswordUseCase.execute("user-1", {
      current_password: "oldPassword",
      new_password: "newPassword",
      confirm_new_password: "newPassword",
    });

    expect(result).toBeUndefined();
    expect(mockUserRepository.updatePassword).toHaveBeenCalledWith("user-1", "newHashedPassword");
  });

  it("should throw error if user is not found", async () => {
    vi.mocked(mockUserRepository.findById).mockResolvedValue(null);

    await expect(
      updatePasswordUseCase.execute("user-1", {
        current_password: "oldPassword",
        new_password: "newPassword",
        confirm_new_password: "newPassword",
      }),
    ).rejects.toEqual({
      message: "User tidak ditemukan",
      errors: { user: "User tidak ditemukan" },
    });

    expect(mockPasswordService.compare).not.toHaveBeenCalled();
    expect(mockUserRepository.updatePassword).not.toHaveBeenCalled();
  });

  it("should throw error if current password is wrong", async () => {
    vi.mocked(mockUserRepository.findById).mockResolvedValue(mockUser as any);
    vi.mocked(mockPasswordService.compare).mockResolvedValue(false);

    await expect(
      updatePasswordUseCase.execute("user-1", {
        current_password: "wrongPassword",
        new_password: "newPassword",
        confirm_new_password: "newPassword",
      }),
    ).rejects.toEqual({
      message: "Password saat ini salah",
      errors: { current_password: "Password saat ini salah" },
    });

    expect(mockUserRepository.updatePassword).not.toHaveBeenCalled();
  });
});
