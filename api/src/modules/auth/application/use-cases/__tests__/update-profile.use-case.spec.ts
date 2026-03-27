import { describe, it, expect, vi, beforeEach } from "vitest";
import { UpdateProfileUseCase } from "../update-profile.use-case.js";
import type { UserRepository } from "../../../domain/repositories/user.repository.interface.js";

describe("UpdateProfileUseCase", () => {
  let updateProfileUseCase: UpdateProfileUseCase;
  let mockUserRepository: UserRepository;

  const mockUser = {
    id: "user-1",
    email: "old@example.com",
    name: "Old Name",
    password: "hashedPassword",
    lastLoginAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  beforeEach(() => {
    mockUserRepository = {
      findById: vi.fn(),
      isEmailTaken: vi.fn(),
      updateProfile: vi.fn(),
    } as unknown as UserRepository;

    updateProfileUseCase = new UpdateProfileUseCase(mockUserRepository);
  });

  it("should update profile successfully", async () => {
    vi.mocked(mockUserRepository.isEmailTaken).mockResolvedValue(false);
    vi.mocked(mockUserRepository.updateProfile).mockResolvedValue({
      ...mockUser,
      name: "New Name",
      email: "new@example.com",
    });

    const result = await updateProfileUseCase.execute("user-1", {
      name: "New Name",
      email: "new@example.com",
    });

    expect(result.user.name).toBe("New Name");
    expect(result.user.email).toBe("new@example.com");
  });

  it("should throw error if email is already taken", async () => {
    vi.mocked(mockUserRepository.isEmailTaken).mockResolvedValue(true);

    await expect(
      updateProfileUseCase.execute("user-1", {
        name: "New Name",
        email: "taken@example.com",
      }),
    ).rejects.toEqual({
      message: "Email sudah digunakan",
      errors: { email: "Email sudah digunakan oleh pengguna lain" },
    });
  });
});
