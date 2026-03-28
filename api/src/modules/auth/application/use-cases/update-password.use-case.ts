import { BadRequestError } from "../../../../lib/errors/bad-request.error.js";
import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import type { PasswordService } from "../../domain/services/password.service.interface.js";
import type { UpdatePasswordRequest } from "../dtos/auth.dto.js";

export class UpdatePasswordUseCase {
  constructor(
    private userRepository: UserRepository,
    private passwordService: PasswordService,
  ) {}

  async execute(userId: string, data: UpdatePasswordRequest): Promise<void> {
    const user = await this.userRepository.findById(userId);

    if (!user) {
      throw {
        message: "User tidak ditemukan",
        errors: { user: "User tidak ditemukan" },
      };
    }

    const isPasswordValid = await this.passwordService.compare(
      data.current_password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new BadRequestError("Password saat ini salah", {
        current_password: "Password saat ini salah",
      });
    }

    const isSamePassword = await this.passwordService.compare(data.new_password, user.password);

    if (isSamePassword) {
      throw new BadRequestError("Password baru tidak boleh sama dengan password lama", {
        new_password: "Gunakan password yang berbeda",
      });
    }

    const hashedNewPassword = await this.passwordService.hash(data.new_password);

    await this.userRepository.update(userId, {
      password: hashedNewPassword,
    });
  }
}
