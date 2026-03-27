import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { GetUserDevicesQuery, GetUserDevicesResponse } from "../dtos/user-device.dto.js";

export class GetUserDevicesUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(userId: string, query: GetUserDevicesQuery): Promise<GetUserDevicesResponse> {
    const { devices, total } = await this.userDeviceRepository.findMany(userId, query);

    return {
      user_devices: devices,
      meta: {
        page: query.page,
        per_page: query.per_page,
        total,
        total_pages: Math.ceil(total / query.per_page),
      },
    };
  }
}
