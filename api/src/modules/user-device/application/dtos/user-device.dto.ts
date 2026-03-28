import type {
  UserDevicePlatform,
  UserDeviceStatus,
} from "../../../../lib/generated/prisma/enums.js";
import type { PaginationMetaDto } from "../../../../lib/types/pagination-meta-dto.js";
import type { IUserDevice } from "../../domain/entities/user-device.entity.js";

/**
 * Input Data Contracts
 */
export type RegisterUserDeviceRequest = {
  device_id: string;
  device_brand: string;
  device_model: string;
  os_build_id?: string | undefined;
  os_version?: string | undefined;
  fcm_token: string;
  platform: UserDevicePlatform;
};

export type UpdateUserDeviceStatusRequest = {
  device_id: string;
  status: UserDeviceStatus;
};

export type GetUserDevicesQuery = {
  page: number;
  per_page: number;
  search?: string | undefined;
};

export type UpsertUserDeviceData = {
  deviceId: string;
  fcmToken: string;
  deviceBrand?: string | null;
  deviceModel?: string | null;
  osBuildId?: string | null;
  osVersion?: string | null;
  platform: UserDevicePlatform;
};

export type UpdateUserDeviceData = {
  status?: UserDeviceStatus;
  fcmToken?: string;
  deviceBrand?: string | null;
  deviceModel?: string | null;
  osBuildId?: string | null;
  osVersion?: string | null;
  platform?: UserDevicePlatform;
  lastSeenAt?: Date;
};

/**
 * Filter Contracts
 */
export type UserDeviceFilter = {
  search?: string;
};

/**
 * Response Contracts
 */
export type CreateUserDeviceResponse = {
  user_device: IUserDevice;
};

export type GetUserDevicesResponse = {
  user_devices: IUserDevice[];
  meta: PaginationMetaDto;
};

export type GetUserDeviceDetailResponse = {
  user_device: IUserDevice;
};

export type UpdateUserDeviceStatusResponse = {
  user_device: IUserDevice;
};
