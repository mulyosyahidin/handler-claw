import type { UserDevice } from "../../../../../lib/generated/prisma/client.js";
import type { IUserDevice } from "../../domain/entities/user-device.entity.js";

export function toUserDeviceEntity(data: UserDevice): IUserDevice {
  return {
    id: data.id,
    user_id: data.userId,
    status: data.status,
    device_id: data.deviceId,
    device_brand: data.deviceBrand,
    device_model: data.deviceModel,
    os_build_id: data.osBuildId,
    os_version: data.osVersion,
    fcm_token: data.fcmToken,
    platform: data.platform,
    last_seen_at: data.lastSeenAt,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
