import { type UserDevice } from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type {
  UpdateUserDeviceData,
  UserDeviceFilter,
  UpsertUserDeviceData,
} from "../../application/dtos/user-device.dto.js";

export interface UserDeviceRepository {
  upsert(userId: string, data: UpsertUserDeviceData): Promise<UserDevice>;
  update(id: string, data: UpdateUserDeviceData): Promise<UserDevice>;
  findAllByActiveStatus(userId: string): Promise<UserDevice[]>;
  findById(userId: string, id: string): Promise<UserDevice | null>;
  findByDeviceId(userId: string, deviceId: string): Promise<UserDevice | null>;
  findAll(
    userId: string,
    filter: UserDeviceFilter,
    pagination: PaginationType,
  ): Promise<{ devices: UserDevice[]; total: number }>;
}
