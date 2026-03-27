import { describe, it, expect, vi, beforeEach } from "vitest";
import { GetMeUseCase } from "../get-me.use-case.js";
import type { UserRepository } from "../../../domain/repositories/user.repository.interface.js";

describe("GetMeUseCase", () => {
  let getMeUseCase: GetMeUseCase;
  let mockUserRepository: UserRepository;

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
      findById: vi.fn(),
    } as unknown as UserRepository;

    getMeUseCase = new GetMeUseCase(mockUserRepository);
  });

  it("should return user profile successfully", async () => {
    vi.mocked(mockUserRepository.findById).mockResolvedValue(mockUser);

    const result = await getMeUseCase.execute("user-1");

    expect(result.user.id).toBe("user-1");
    expect(result.user.email).toBe("test@example.com");
  });

  it("should throw error if user is not found", async () => {
    vi.mocked(mockUserRepository.findById).mockResolvedValue(null);

    await expect(getMeUseCase.execute("invalid-id")).rejects.toEqual({
      message: "User tidak ditemukan",
      errors: { user: "User tidak valid atau sudah dihapus" },
    });
  });
});
