import type { Prisma } from "../../../../lib/generated/prisma/client.js";
import type { User } from "../entities/user.entity.js";

export interface AuthRepository {
  findByEmail(email: string): Promise<User | null>;
  findById(id: string): Promise<User | null>;
  create(data: Prisma.UserCreateInput): Promise<User>;
  updateLastLogin(userId: string): Promise<void>;
}
