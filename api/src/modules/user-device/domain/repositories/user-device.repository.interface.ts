import { type UserDeviceStatus } from "../../../../lib/generated/prisma/client.js";
import type { UserDevice } from "../entities/user-device.entity.js";
import type { CreateUserDeviceRequest } from "../../application/dtos/user-device.dto.js";

export interface UserDeviceRepository {
  upsert(userId: string, data: CreateUserDeviceRequest): Promise<UserDevice>;
  updateStatus(userId: string, deviceId: string, status: UserDeviceStatus): Promise<UserDevice>;
  findAllActiveByUserId(userId: string): Promise<UserDevice[]>;
  findById(userId: string, id: string): Promise<UserDevice | null>;
  findMany(userId: string, filter: any): Promise<{ devices: UserDevice[]; total: number }>;
}
