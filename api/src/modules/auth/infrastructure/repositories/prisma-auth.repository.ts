import { prisma } from "../../../../config/index.js";
import type { Prisma } from "../../../../lib/generated/prisma/client.js";
import type { AuthRepository } from "../../domain/repositories/auth.repository.interface.js";
import type { User } from "../../domain/entities/user.entity.js";
import { toUserEntity } from "../mappers/user.mapper.js";

export class PrismaAuthRepository implements AuthRepository {
  async findByEmail(email: string): Promise<User | null> {
    const user = await prisma.user.findUnique({ where: { email } });

    return user ? toUserEntity(user) : null;
  }

  async findById(id: string): Promise<User | null> {
    const user = await prisma.user.findUnique({ where: { id } });

    return user ? toUserEntity(user) : null;
  }

  async create(data: Prisma.UserCreateInput): Promise<User> {
    const user = await prisma.user.create({ data });

    return toUserEntity(user);
  }

  async updateLastLogin(userId: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { lastLoginAt: new Date() },
    });
  }
}
