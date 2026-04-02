import type { User } from "../../../../lib/generated/prisma/client.js";
import { prisma } from "../../../../config/index.js";
import type {
  CreateUserData,
  UpdateUserData,
  UserFilter,
} from "../../application/dtos/auth.dto.js";
import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";

export class PrismaUserRepository implements UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
    });
  }

  async update(id: string, data: UpdateUserData): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: {
        ...(data.email !== undefined ? { email: data.email } : {}),
        ...(data.name !== undefined ? { name: data.name } : {}),
        ...(data.password !== undefined ? { password: data.password } : {}),
        ...(data.lastLoginAt !== undefined ? { lastLoginAt: data.lastLoginAt } : {}),
        ...(data.avatarUrl !== undefined ? { avatarUrl: data.avatarUrl } : {}),
      },
    });
  }

  async create(data: CreateUserData): Promise<User> {
    return prisma.user.create({
      data: {
        email: data.email,
        name: data.name,
        driver: data.driver,
        password: data.password ?? null,
        avatarUrl: data.avatarUrl ?? null,
      },
    });
  }

  async findFirst(where: UserFilter): Promise<User | null> {
    return prisma.user.findFirst({
      where: where as any,
    });
  }
}
