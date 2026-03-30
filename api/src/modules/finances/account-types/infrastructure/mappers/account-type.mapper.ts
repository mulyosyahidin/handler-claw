import type { AccountType } from "../../../../../lib/generated/prisma/client.js";
import type { IAccountType } from "../../domain/entities/account-type.entity.js";

export function toAccountTypeEntity(data: AccountType): IAccountType {
  return {
    id: data.id,
    user_id: data.userId,
    name: data.name,
    category: data.category,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
