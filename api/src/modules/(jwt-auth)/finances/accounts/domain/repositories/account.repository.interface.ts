import {
  type Account,
  type BalanceSnapshot,
  type AccountType,
} from "../../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../../lib/types/pagination.type.js";
import type { CreateAccountData, GetAccountsQuery } from "../../application/dtos/account.dto.js";

export type UpdateAccountData = Partial<CreateAccountData>;

export interface AccountRepository {
  create(
    userId: string,
    data: CreateAccountData,
  ): Promise<Account & { accountType: AccountType; balances: BalanceSnapshot[] }>;
  findAll(
    userId: string,
    filter: GetAccountsQuery,
    pagination: PaginationType,
  ): Promise<{
    accounts: (Account & { accountType: AccountType; balances: BalanceSnapshot[] })[];
    total: number;
  }>;
  findById(
    userId: string,
    id: string,
  ): Promise<(Account & { accountType: AccountType; balances: BalanceSnapshot[] }) | null>;
  findByNameAndType(userId: string, name: string, accountTypeId: string): Promise<Account | null>;
  update(
    id: string,
    data: UpdateAccountData,
  ): Promise<Account & { accountType: AccountType; balances: BalanceSnapshot[] }>;
  softDelete(id: string): Promise<Account>;
}
