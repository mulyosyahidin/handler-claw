import type {
  UserDevicePlatform,
  UserDeviceStatus,
} from "../../../../lib/generated/prisma/enums.js";

export type UserDevice = {
  id: string;
  user_id: string;
  status: UserDeviceStatus;
  device_id: string;
  device_brand: string | null;
  device_model: string | null;
  os_version: string | null;
  fcm_token: string;
  platform: UserDevicePlatform;
  last_seen_at: Date | null;
  created_at: Date;
  updated_at: Date;
};
