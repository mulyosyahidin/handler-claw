import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { CreateUserDeviceRequest, CreateUserDeviceResponse } from "../dtos/user-device.dto.js";

export class RegisterUserDeviceUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(userId: string, input: CreateUserDeviceRequest): Promise<CreateUserDeviceResponse> {
    const device = await this.userDeviceRepository.upsert(userId, input);

    return {
      user_device: device,
    };
  }
}
