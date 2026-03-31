import type {
  Account,
  AccountType,
  BalanceSnapshot,
} from "../../../../../lib/generated/prisma/client.js";
import type { AccountDto } from "../../application/dtos/account.dto.js";

type AccountWithRelations = Account & {
  accountType: AccountType;
  balances: BalanceSnapshot[];
};

export function toAccountEntity(data: AccountWithRelations): AccountDto {
  return {
    id: data.id,
    user_id: data.userId,
    name: data.name,
    account_type_id: data.accountTypeId,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
    current_amount: Number(data.balances[0]?.amount ?? 0),
    category: data.accountType.category,
  };
}
