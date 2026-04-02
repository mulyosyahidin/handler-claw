import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import { toUserDeviceEntity } from "../../infrastructure/mappers/user-device.mapper.js";
import type {
  CreateUserDeviceResponse,
  RegisterUserDeviceRequest,
  UpsertUserDeviceData,
} from "../dtos/user-device.dto.js";

export class RegisterUserDeviceUseCase {
  constructor(private userDeviceRepository: UserDeviceRepository) {}

  async execute(
    userId: string,
    input: RegisterUserDeviceRequest,
  ): Promise<CreateUserDeviceResponse> {
    const data: UpsertUserDeviceData = {
      deviceId: input.device_id,
      fcmToken: input.fcm_token,
      deviceBrand: input.device_brand ?? null,
      deviceModel: input.device_model ?? null,
      osBuildId: input.os_build_id ?? null,
      osVersion: input.os_version ?? null,
      platform: input.platform,
    };

    const device = await this.userDeviceRepository.upsert(userId, data);

    return {
      user_device: toUserDeviceEntity(device),
    };
  }
}
