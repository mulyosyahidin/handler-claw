import type { Account } from "../../../../../lib/generated/prisma/client.js";
import type { IAccount } from "../../domain/entities/account.entity.js";

export function toAccountEntity(data: Account): IAccount {
  return {
    id: data.id,
    user_id: data.userId,
    name: data.name,
    account_type_id: data.accountTypeId,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
