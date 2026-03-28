import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import { toUserDeviceEntity } from "../../infrastructure/mappers/user-device.mapper.js";
import type { GetUserDevicesQuery, GetUserDevicesResponse } from "../dtos/user-device.dto.js";

export class GetUserDevicesUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(userId: string, query: GetUserDevicesQuery): Promise<GetUserDevicesResponse> {
    const { page, per_page, search } = query;

    const skip = (page - 1) * per_page;
    const take = per_page;

    const { devices, total } = await this.userDeviceRepository.findAll(
      userId,
      {
        ...(search !== undefined ? { search } : {}),
      },
      { skip, take },
    );

    return {
      user_devices: devices.map(toUserDeviceEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    };
  }
}
