import prisma from "../config/prisma.js";
import { createSuccessResponse, type SuccessResponse } from "../lib/types/response.js";
import type {
  CreateUserDeviceResponseData,
  GetUserDevicesResponseData,
  GetUserDeviceDetailResponseData,
} from "../lib/types/data/index.js";
import type {
  CreateUserDeviceInput,
  UpdateUserDeviceStatusInput,
  GetUserDevicesQuery,
} from "../lib/schemas/user-device.schema.js";
import { toUserDeviceEntity } from "../lib/mappers/index.js";
import { UserDeviceStatus, type UserDevice, Prisma } from "../lib/generated/prisma/client.js";

export class UserDeviceService {
  async createDevice(
    userId: string,
    data: CreateUserDeviceInput,
  ): Promise<SuccessResponse<CreateUserDeviceResponseData>> {
    const device = await prisma.userDevice.upsert({
      where: {
        fcmToken: data.fcm_token,
      },
      update: {
        userId,
        deviceId: data.device_id,
        deviceBrand: data.device_brand ?? null,
        deviceModel: data.device_model ?? null,
        osVersion: data.os_version ?? null,
        platform: data.platform,
        lastSeenAt: new Date(),
        status: "ACTIVE",
      },
      create: {
        userId,
        deviceId: data.device_id,
        deviceBrand: data.device_brand ?? null,
        deviceModel: data.device_model ?? null,
        osVersion: data.os_version ?? null,
        fcmToken: data.fcm_token,
        platform: data.platform,
        lastSeenAt: new Date(),
        status: "ACTIVE",
      },
    });

    return createSuccessResponse("Berhasil mendaftarkan perangkat", {
      user_device: toUserDeviceEntity(device),
    });
  }

  async getDevices(
    userId: string,
    query: GetUserDevicesQuery,
  ): Promise<SuccessResponse<GetUserDevicesResponseData>> {
    const { page, per_page, search } = query;
    const skip = (page - 1) * per_page;
    const take = per_page;

    const searchFilter: Prisma.UserDeviceWhereInput = search
      ? {
          OR: [
            { deviceBrand: { contains: search, mode: "insensitive" } },
            { deviceModel: { contains: search, mode: "insensitive" } },
            { deviceId: { contains: search, mode: "insensitive" } },
          ],
        }
      : {};

    const where: Prisma.UserDeviceWhereInput = {
      AND: [{ userId }, searchFilter],
    };

    const [total, devices] = await Promise.all([
      prisma.userDevice.count({ where }),
      prisma.userDevice.findMany({
        where,
        skip,
        take,
        orderBy: { updatedAt: "desc" },
      }),
    ]);

    return createSuccessResponse("Berhasil mengambil daftar perangkat", {
      user_devices: devices.map(toUserDeviceEntity),
      meta: {
        page,
        per_page,
        total,
        total_pages: Math.ceil(total / per_page),
      },
    });
  }

  async findAllUserDevices(userId: string): Promise<UserDevice[]> {
    return await prisma.userDevice.findMany({
      where: { userId, status: UserDeviceStatus.ACTIVE },
    });
  }

  async getDeviceById(
    userId: string,
    id: string,
  ): Promise<SuccessResponse<GetUserDeviceDetailResponseData>> {
    const device = await prisma.userDevice.findUniqueOrThrow({
      where: {
        id,
        userId,
      },
    });

    return createSuccessResponse("Berhasil mengambil detail perangkat", {
      user_device: toUserDeviceEntity(device),
    });
  }

  async updateDeviceStatus(
    userId: string,
    data: UpdateUserDeviceStatusInput,
  ): Promise<SuccessResponse<CreateUserDeviceResponseData>> {
    const device = await prisma.userDevice.update({
      where: {
        fcmToken: data.fcm_token,
        userId: userId,
      },
      data: {
        status: data.status,
      },
    });

    return createSuccessResponse("Berhasil memperbarui status perangkat", {
      user_device: toUserDeviceEntity(device),
    });
  }
}

export const userDeviceService = new UserDeviceService();
