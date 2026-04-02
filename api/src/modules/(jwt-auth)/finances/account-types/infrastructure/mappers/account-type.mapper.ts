import type { AccountType } from "../../../../../../lib/generated/prisma/client.js";
import type { IAccountType } from "../../domain/entities/account-type.entity.js";
import type {
  AccountTypeWithMetrics,
  IAccountTypeWithMetrics,
} from "../../application/dtos/account-type.dto.js";

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

export function toAccountTypeWithMetricsEntity(
  data: AccountTypeWithMetrics,
): IAccountTypeWithMetrics {
  return {
    ...toAccountTypeEntity(data),
    current_total_amount: data.current_total_amount,
    account_count: data.account_count,
    accounts: data.accounts.map((acc) => ({
      id: acc.id,
      name: acc.name,
      category: acc.category,
      current_amount: acc.current_amount,
    })),
  };
}
