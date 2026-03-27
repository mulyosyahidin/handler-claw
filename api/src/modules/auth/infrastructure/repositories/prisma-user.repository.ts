import type { User as PrismaUser } from "../../../../lib/generated/prisma/client.js";
import { prisma } from "../../../../config/index.js";
import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";

export class PrismaUserRepository implements UserRepository {
  async findByEmail(email: string): Promise<(PrismaUser & { id: string }) | null> {
    return prisma.user.findUnique({
      where: { email },
    });
  }

  async findById(id: string): Promise<(PrismaUser & { id: string }) | null> {
    return prisma.user.findUnique({
      where: { id },
    });
  }

  async updateLastLogin(id: string): Promise<void> {
    await prisma.user.update({
      where: { id },
      data: { lastLoginAt: new Date() },
    });
  }

  async updateProfile(id: string, name: string, email: string): Promise<PrismaUser> {
    return prisma.user.update({
      where: { id },
      data: { name, email },
    });
  }

  async updatePassword(id: string, hashedNewPassword: string): Promise<void> {
    await prisma.user.update({
      where: { id },
      data: { password: hashedNewPassword },
    });
  }

  async isEmailTaken(email: string, excludeUserId: string): Promise<boolean> {
    const user = await prisma.user.findFirst({
      where: {
        email,
        NOT: { id: excludeUserId },
      },
    });

    return !!user;
  }
}
