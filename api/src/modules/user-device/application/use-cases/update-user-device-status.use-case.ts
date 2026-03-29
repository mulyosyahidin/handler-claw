import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { UserDeviceStatus } from "../../../../lib/generated/prisma/client.js";
import type {
  UpdateUserDeviceStatusRequest,
  UpdateUserDeviceStatusResponse,
} from "../dtos/user-device.dto.js";
import { toUserDeviceEntity } from "../../infrastructure/mappers/user-device.mapper.js";
import { NotFoundError } from "../../../../lib/errors/not-found.error.js";

export class UpdateUserDeviceStatusUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(
    userId: string,
    data: UpdateUserDeviceStatusRequest,
  ): Promise<UpdateUserDeviceStatusResponse> {
    const device = await this.userDeviceRepository.findByDeviceId(userId, data.device_id);

    if (!device) {
      throw new NotFoundError("Device tidak ditemukan");
    }

    const updated = await this.userDeviceRepository.update(device.id, {
      status: data.status as UserDeviceStatus,
    });

    return {
      user_device: toUserDeviceEntity(updated),
    };
  }
}
