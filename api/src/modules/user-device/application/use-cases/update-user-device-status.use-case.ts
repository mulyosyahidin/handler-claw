import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { UserDeviceStatus } from "../../../../lib/generated/prisma/client.js";
import type {
  UpdateUserDeviceStatusRequest,
  UpdateUserDeviceStatusResponse,
} from "../dtos/user-device.dto.js";

export class UpdateUserDeviceStatusUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(
    userId: string,
    data: UpdateUserDeviceStatusRequest,
  ): Promise<UpdateUserDeviceStatusResponse> {
    await this.userDeviceRepository.updateStatus(
      userId,
      data.device_id,
      data.status as UserDeviceStatus,
    );
    return { success: true };
  }
}
