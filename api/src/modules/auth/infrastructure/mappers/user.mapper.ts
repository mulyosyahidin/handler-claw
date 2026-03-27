import { type User as PrismaUser } from "../../../../lib/generated/prisma/client.js";
import { type User } from "../../domain/entities/user.entity.js";

export const toUserEntity = (user: PrismaUser): User => {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    last_login_at: user.lastLoginAt,
    created_at: user.createdAt,
    updated_at: user.updatedAt,
  };
};
