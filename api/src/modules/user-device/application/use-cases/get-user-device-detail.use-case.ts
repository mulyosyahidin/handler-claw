import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { GetUserDeviceParams, GetUserDeviceDetailResponse } from "../dtos/user-device.dto.js";

export class GetUserDeviceDetailUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(userId: string, params: GetUserDeviceParams): Promise<GetUserDeviceDetailResponse> {
    const device = await this.userDeviceRepository.findById(userId, params.id);

    if (!device) {
      throw new Error("Device not found");
    }

    return {
      user_device: device,
    };
  }
}
