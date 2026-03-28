import { prisma } from "../../../../config/index.js";
import {
  Prisma,
  UserDeviceStatus,
  type UserDevice,
} from "../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../lib/types/pagination.type.js";
import type {
  UpdateUserDeviceData,
  UpsertUserDeviceData,
  UserDeviceFilter,
} from "../../application/dtos/user-device.dto.js";
import type { UserDeviceRepository } from "../../domain/repositories/user-device.repository.interface.js";

export class PrismaUserDeviceRepository implements UserDeviceRepository {
  async upsert(userId: string, data: UpsertUserDeviceData): Promise<UserDevice> {
    return prisma.userDevice.upsert({
      where: {
        deviceId: data.deviceId,
      },
      update: {
        userId,
        fcmToken: data.fcmToken,
        status: UserDeviceStatus.ACTIVE,
        deviceBrand: data.deviceBrand ?? null,
        deviceModel: data.deviceModel ?? null,
        osBuildId: data.osBuildId ?? null,
        osVersion: data.osVersion ?? null,
        platform: data.platform,
        lastSeenAt: new Date(),
      },
      create: {
        userId,
        deviceId: data.deviceId,
        fcmToken: data.fcmToken,
        status: UserDeviceStatus.ACTIVE,
        deviceBrand: data.deviceBrand ?? null,
        deviceModel: data.deviceModel ?? null,
        osBuildId: data.osBuildId ?? null,
        osVersion: data.osVersion ?? null,
        platform: data.platform,
        lastSeenAt: new Date(),
      },
    });
  }

  async update(id: string, data: UpdateUserDeviceData): Promise<UserDevice> {
    return prisma.userDevice.update({
      where: { id },
      data: {
        ...(data.status !== undefined ? { status: data.status } : {}),
        ...(data.fcmToken !== undefined ? { fcmToken: data.fcmToken } : {}),
        ...(data.deviceBrand !== undefined ? { deviceBrand: data.deviceBrand } : {}),
        ...(data.deviceModel !== undefined ? { deviceModel: data.deviceModel } : {}),
        ...(data.osBuildId !== undefined ? { osBuildId: data.osBuildId } : {}),
        ...(data.osVersion !== undefined ? { osVersion: data.osVersion } : {}),
        ...(data.platform !== undefined ? { platform: data.platform } : {}),
        ...(data.lastSeenAt !== undefined ? { lastSeenAt: data.lastSeenAt } : {}),
      },
    });
  }

  async findAllByActiveStatus(userId: string): Promise<UserDevice[]> {
    return prisma.userDevice.findMany({
      where: { userId, status: "ACTIVE" },
    });
  }

  async findById(userId: string, id: string): Promise<UserDevice | null> {
    const device = await prisma.userDevice.findUnique({
      where: { id },
    });

    if (!device || device.userId !== userId) return null;

    return device;
  }

  async findAll(
    userId: string,
    filter: UserDeviceFilter,
    pagination: PaginationType,
  ): Promise<{ devices: UserDevice[]; total: number }> {
    const { skip, take } = pagination;
    const normalizedSearch = filter.search?.trim();

    const where: Prisma.UserDeviceWhereInput = {
      userId,
      ...(normalizedSearch
        ? {
            OR: [
              { deviceId: { contains: normalizedSearch, mode: "insensitive" } },
              { deviceBrand: { contains: normalizedSearch, mode: "insensitive" } },
              { deviceModel: { contains: normalizedSearch, mode: "insensitive" } },
            ],
          }
        : {}),
    };

    const [devices, total] = await Promise.all([
      prisma.userDevice.findMany({
        where,
        skip,
        take,
        orderBy: { updatedAt: "desc" },
      }),
      prisma.userDevice.count({ where }),
    ]);

    return { devices, total };
  }
}
