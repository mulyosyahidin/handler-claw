import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import type { UpdateProfileRequest, UpdateProfileResponse } from "../dtos/auth.dto.js";

export class UpdateProfileUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userId: string, data: UpdateProfileRequest): Promise<UpdateProfileResponse> {
    const isEmailTaken = await this.userRepository.isEmailTaken(data.email, userId);

    if (isEmailTaken) {
      throw {
        message: "Email sudah digunakan",
        errors: { email: "Email sudah digunakan oleh pengguna lain" },
      };
    }

    const updatedUser = await this.userRepository.updateProfile(userId, data.name, data.email);

    return {
      user: toUserEntity(updatedUser),
    };
  }
}
