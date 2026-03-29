import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import type { UpdateAvatarRequest, UpdateAvatarResponse } from "../dtos/auth.dto.js";

export class UpdateAvatarUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userId: string, data: UpdateAvatarRequest): Promise<UpdateAvatarResponse> {
    const updatedUser = await this.userRepository.update(userId, {
      avatarUrl: data.avatar_url,
    });

    return {
      user: toUserEntity(updatedUser),
    };
  }
}
