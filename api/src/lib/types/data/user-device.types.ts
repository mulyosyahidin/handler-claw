import type { IUserDevice } from "../domain/index.js";

export interface CreateUserDeviceResponseData {
  user_device: IUserDevice;
}

export interface GetUserDevicesResponseData {
  user_devices: IUserDevice[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
}
