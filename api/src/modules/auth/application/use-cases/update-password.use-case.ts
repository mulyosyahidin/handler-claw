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
      throw {
        message: "Password saat ini salah",
        errors: { current_password: "Password saat ini salah" },
      };
    }

    const hashedNewPassword = await this.passwordService.hash(data.new_password);

    await this.userRepository.updatePassword(userId, hashedNewPassword);
  }
}
