import type { User as PrismaUser } from "../../../../lib/generated/prisma/client.js";

export interface UserRepository {
  findByEmail(email: string): Promise<(PrismaUser & { id: string }) | null>;
  findById(id: string): Promise<(PrismaUser & { id: string }) | null>;
  updateLastLogin(id: string): Promise<void>;
  updateProfile(id: string, name: string, email: string): Promise<PrismaUser>;
  updatePassword(id: string, hashedNewPassword: string): Promise<void>;
  isEmailTaken(email: string, excludeUserId: string): Promise<boolean>;
}
