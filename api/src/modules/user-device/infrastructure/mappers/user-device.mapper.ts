import type { UserDevice } from "../../../../lib/generated/prisma/client.js";
import type { UserDevice as Entity } from "../../domain/entities/user-device.entity.js";

export function toUserDeviceEntity(p: UserDevice): Entity {
  return {
    id: p.id,
    user_id: p.userId,
    status: p.status,
    device_id: p.deviceId,
    device_brand: p.deviceBrand,
    device_model: p.deviceModel,
    os_version: p.osVersion,
    fcm_token: p.fcmToken,
    platform: p.platform,
    last_seen_at: p.lastSeenAt,
    created_at: p.createdAt,
    updated_at: p.updatedAt,
  };
}
