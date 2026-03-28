import { type User as PrismaUser } from "../../../../lib/generated/prisma/client.js";
import type { IUser } from "../../domain/entities/user.entity.js";

export function toUserEntity(data: PrismaUser): IUser {
  return {
    id: data.id,
    email: data.email,
    name: data.name,
    last_login_at: data.lastLoginAt,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
