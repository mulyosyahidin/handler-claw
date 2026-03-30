import type { PaginationMetaDto } from "../../../../../lib/types/pagination-meta-dto.js";
import type { IAccount } from "../../domain/entities/account.entity.js";

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
  account: IAccount;
};

export type GetAccountsResponse = {
  accounts: IAccount[];
  meta: PaginationMetaDto;
};

export type GetAccountDetailResponse = {
  account: IAccount;
};

export type UpdateAccountResponse = {
  account: IAccount;
};
