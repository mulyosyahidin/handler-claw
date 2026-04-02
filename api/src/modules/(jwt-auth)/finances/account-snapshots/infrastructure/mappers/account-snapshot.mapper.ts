import type { BalanceSnapshot } from "../../../../../../lib/generated/prisma/client.js";
import type { IAccountSnapshot } from "../../domain/entities/account-snapshot.entity.js";

export function toAccountSnapshotEntity(data: BalanceSnapshot): IAccountSnapshot {
  return {
    id: data.id,
    account_id: data.accountId,
    amount: Number(data.amount),
    date: data.date,
    note: data.note,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
