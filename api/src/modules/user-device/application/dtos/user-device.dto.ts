import type { UserDevicePlatform } from "../../../../lib/generated/prisma/enums.js";
import type { UserDevice } from "../../domain/entities/user-device.entity.js";

/**
 * Request Contracts
 */
export type CreateUserDeviceRequest = {
  device_id: string;
  device_brand?: string;
  device_model?: string;
  os_version?: string;
  fcm_token: string;
  platform: UserDevicePlatform;
};

export type UpdateUserDeviceStatusRequest = {
  device_id: string;
  status: string;
};

export type GetUserDevicesQuery = {
  page: number;
  per_page: number;
  search?: string;
};

export type GetUserDeviceParams = {
  id: string;
};

/**
 * Response Contracts
 */
export type CreateUserDeviceResponse = {
  user_device: UserDevice;
};

export type GetUserDevicesResponse = {
  user_devices: UserDevice[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
};

export type GetUserDeviceDetailResponse = {
  user_device: UserDevice;
};

export type UpdateUserDeviceStatusResponse = {
  success: boolean;
};
