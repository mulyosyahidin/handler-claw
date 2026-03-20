import type { User } from "../generated/prisma/client.js";
import type { IUser } from "../types/domain/index.js";

export function toUserEntity(prismaUser: User): IUser {
  return {
    id: prismaUser.id,
    email: prismaUser.email,
    name: prismaUser.name,
    last_login_at: prismaUser.lastLoginAt,
    created_at: prismaUser.createdAt,
    updated_at: prismaUser.updatedAt,
  };
}
