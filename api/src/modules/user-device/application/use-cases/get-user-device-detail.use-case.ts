import { NotFoundError } from "../../../../lib/errors/not-found.error.js";
import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import { toUserDeviceEntity } from "../../infrastructure/mappers/user-device.mapper.js";
import type { GetUserDeviceDetailResponse } from "../dtos/user-device.dto.js";

export class GetUserDeviceDetailUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(userId: string, id: string): Promise<GetUserDeviceDetailResponse> {
    const device = await this.userDeviceRepository.findById(userId, id);

    if (!device) {
      throw new NotFoundError("Device not found");
    }

    return {
      user_device: toUserDeviceEntity(device),
    };
  }
}
