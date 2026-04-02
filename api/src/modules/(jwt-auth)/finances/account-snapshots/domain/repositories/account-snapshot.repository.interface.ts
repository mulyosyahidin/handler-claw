import { type BalanceSnapshot } from "../../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../../lib/types/pagination.type.js";
import type {
  CreateAccountSnapshotData,
  GetAccountSnapshotsQuery,
} from "../../application/dtos/account-snapshot.dto.js";

export type UpdateAccountSnapshotData = Partial<Omit<CreateAccountSnapshotData, "account_id">>;

export interface AccountSnapshotRepository {
  create(data: CreateAccountSnapshotData): Promise<BalanceSnapshot>;
  findAll(
    userId: string,
    filter: GetAccountSnapshotsQuery,
    pagination: PaginationType,
  ): Promise<{ snapshots: BalanceSnapshot[]; total: number }>;
  findById(userId: string, id: string): Promise<BalanceSnapshot | null>;
  findByDate(accountId: string, date: Date): Promise<BalanceSnapshot | null>;
  update(id: string, data: UpdateAccountSnapshotData): Promise<BalanceSnapshot>;
  softDelete(id: string): Promise<BalanceSnapshot>;
}
