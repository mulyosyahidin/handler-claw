import { type Account, type BalanceSnapshot } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { CreateAccountData, GetAccountsQuery } from "../../application/dtos/account.dto.js";

export type UpdateAccountData = Partial<CreateAccountData>;

export interface AccountRepository {
  create(userId: string, data: CreateAccountData): Promise<Account>;
  findAll(
    userId: string,
    filter: GetAccountsQuery,
    pagination: PaginationType,
  ): Promise<{ accounts: Account[]; total: number }>;
  findById(
    userId: string,
    id: string,
  ): Promise<(Account & { balances?: BalanceSnapshot[] }) | null>;
  findByName(userId: string, name: string): Promise<Account | null>;
  update(id: string, data: UpdateAccountData): Promise<Account>;
  softDelete(id: string): Promise<Account>;
}
