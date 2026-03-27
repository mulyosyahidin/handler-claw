import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import type { GetMeResponse } from "../dtos/auth.dto.js";

export class GetMeUseCase {
  constructor(private userRepository: UserRepository) {}

  async execute(userId: string): Promise<GetMeResponse> {
    const user = await this.userRepository.findById(userId);

    if (!user) {
      throw {
        message: "User tidak ditemukan",
        errors: { user: "User tidak valid atau sudah dihapus" },
      };
    }

    return {
      user: toUserEntity(user),
    };
  }
}
