import { BadRequestError } from "../../../../lib/errors/bad-request.error.js";
import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import type { UpdateProfileRequest, UpdateProfileResponse } from "../dtos/auth.dto.js";

export class UpdateProfileUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userId: string, data: UpdateProfileRequest): Promise<UpdateProfileResponse> {
    if (
      await this.userRepository.findFirst({
        email: data.email,
        NOT: { id: userId },
      })
    ) {
      throw new BadRequestError("Email sudah digunakan");
    }

    const updatedUser = await this.userRepository.update(userId, {
      name: data.name,
      email: data.email,
    });

    return {
      user: toUserEntity(updatedUser),
    };
  }
}
