import type { PaginationMetaDto } from "../../../../../../lib/types/pagination-meta-dto.js";
import type { IAccount } from "../../domain/entities/account.entity.js";
export type AccountDto = Omit<IAccount, "balances"> & {
  current_amount: number;
  category: string;
};

/**
 * Input Data Contracts
 */
export type CreateAccountData = {
  name: string;
  account_type_id: string;
};

export type CreateAccountRequest = {
  name: string;
  account_type_id: string;
};

export type UpdateAccountRequest = {
  name?: string | undefined;
  account_type_id?: string | undefined;
};

export type GetAccountsQuery = {
  page: number;
  per_page: number;
  search?: string | undefined;
};

/**
 * Response Contracts
 */
export type CreateAccountResponse = {
  account: AccountDto;
};

export type GetAccountsResponse = {
  accounts: AccountDto[];
  meta: PaginationMetaDto;
};

export type GetAccountDetailResponse = {
  account: AccountDto;
};

export type UpdateAccountResponse = {
  account: AccountDto;
};
