import type { Account, BalanceSnapshot } from "../../../../../lib/generated/prisma/client.js";
import { toAccountSnapshotEntity } from "../../../account-snapshots/infrastructure/mappers/account-snapshot.mapper.js";
import type { IAccount } from "../../domain/entities/account.entity.js";

type AccountWithBalances = Account & {
  balances?: BalanceSnapshot[];
};

export function toAccountEntity(data: AccountWithBalances): IAccount {
  return {
    id: data.id,
    user_id: data.userId,
    name: data.name,
    account_type_id: data.accountTypeId,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
    balances: data.balances ? data.balances.map(toAccountSnapshotEntity) : undefined,
  };
}
