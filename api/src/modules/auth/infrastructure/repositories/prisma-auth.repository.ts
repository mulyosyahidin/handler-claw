import { prisma } from "../../../../config/index.js";
import type { User } from "../../../../lib/generated/prisma/client.js";
import type { AuthRepository } from "../../domain/repositories/auth.repository.interface.js";
import type { UpdateUserData } from "../../application/dtos/auth.dto.js";

export class PrismaAuthRepository implements AuthRepository {
  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async update(id: string, data: UpdateUserData): Promise<User> {
    return prisma.user.update({
      where: { id },
      data: {
        ...(data.email !== undefined ? { email: data.email } : {}),
        ...(data.name !== undefined ? { name: data.name } : {}),
        ...(data.password !== undefined ? { password: data.password } : {}),
        ...(data.lastLoginAt !== undefined ? { lastLoginAt: data.lastLoginAt } : {}),
      },
    });
  }
}
