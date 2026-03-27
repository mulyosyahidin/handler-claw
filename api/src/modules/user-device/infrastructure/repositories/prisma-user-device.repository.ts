import { prisma } from "../../../../config/index.js";
import { type UserDeviceStatus } from "../../../../lib/generated/prisma/client.js";
import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";
import type { UserDevice } from "../../domain/entities/user-device.entity.js";
import { toUserDeviceEntity } from "../mappers/user-device.mapper.js";
import type { CreateUserDeviceRequest } from "../../application/dtos/user-device.dto.js";

export class PrismaUserDeviceRepository implements UserDeviceRepository {
  async upsert(userId: string, data: CreateUserDeviceRequest): Promise<UserDevice> {
    const { device_id: deviceId } = data;

    const result = await prisma.userDevice.upsert({
      where: {
        deviceId: deviceId,
      },
      update: {
        userId,
        fcmToken: data.fcm_token,
        status: "ACTIVE",
        deviceBrand: data.device_brand ?? null,
        deviceModel: data.device_model ?? null,
        osVersion: data.os_version ?? null,
        platform: data.platform,
        lastSeenAt: new Date(),
      },
      create: {
        deviceId,
        userId,
        fcmToken: data.fcm_token,
        status: "ACTIVE",
        deviceBrand: data.device_brand ?? null,
        deviceModel: data.device_model ?? null,
        osVersion: data.os_version ?? null,
        platform: data.platform,
        lastSeenAt: new Date(),
      },
    });

    return toUserDeviceEntity(result);
  }

  async updateStatus(
    userId: string,
    deviceId: string,
    status: UserDeviceStatus,
  ): Promise<UserDevice> {
    const device = await prisma.userDevice.findFirst({
      where: { userId, deviceId },
    });

    if (!device) {
      throw new Error("Device tidak ditemukan");
    }

    const updated = await prisma.userDevice.update({
      where: { id: device.id },
      data: { status, updatedAt: new Date() },
    });

    return toUserDeviceEntity(updated);
  }

  async findAllActiveByUserId(userId: string): Promise<UserDevice[]> {
    const devices = await prisma.userDevice.findMany({
      where: { userId, status: "ACTIVE" },
    });
    
    return devices.map(toUserDeviceEntity);
  }

  async findById(userId: string, id: string): Promise<UserDevice | null> {
    const device = await prisma.userDevice.findFirst({
      where: { id, userId },
    });
    return device ? toUserDeviceEntity(device) : null;
  }

  async findMany(userId: string, filter: any): Promise<{ devices: UserDevice[]; total: number }> {
    const { page = 1, per_page = 10 } = filter;
    const skip = (page - 1) * per_page;
    const take = per_page;

    const [devices, total] = await Promise.all([
      prisma.userDevice.findMany({
        where: { userId },
        skip,
        take,
        orderBy: { updatedAt: "desc" },
      }),
      prisma.userDevice.count({ where: { userId } }),
    ]);

    return {
      devices: devices.map(toUserDeviceEntity),
      total,
    };
  }
}
