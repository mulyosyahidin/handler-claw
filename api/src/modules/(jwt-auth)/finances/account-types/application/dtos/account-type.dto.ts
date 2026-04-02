import type { AccountType } from "../../../../../../lib/generated/prisma/client.js";
import type { PaginationMetaDto } from "../../../../../../lib/types/pagination-meta-dto.js";
import type { IAccountType } from "../../domain/entities/account-type.entity.js";
import type { AccountCategory } from "../../../../../../lib/generated/prisma/enums.js";
import type { FinanceOverviewAccountItem } from "../../../overview/application/dtos/finance-overview.dto.js";

/**
 * Shared Data Structures
 */
export type AccountTypeCategorySummary = {
  name: string;
  total_account_types: number;
  total_amount: number;
};

export type AccountTypeWithMetrics = AccountType & {
  current_total_amount: number;
  account_count: number;
  accounts: {
    id: string;
    name: string;
    category: AccountCategory;
    current_amount: number;
  }[];
};

export type FindAllAccountTypesResult = {
  accountTypes: AccountTypeWithMetrics[];
  total: number;
  categories: AccountTypeCategorySummary[];
};

/**
 * Input Data Contracts
 */
export type CreateAccountTypeData = {
  name: string;
  category: AccountCategory;
};

export type UpdateAccountTypeData = Partial<CreateAccountTypeData>;

export type CreateAccountTypeRequest = {
  name: string;
  category: AccountCategory;
};

export type UpdateAccountTypeRequest = {
  name?: string | undefined;
  category?: AccountCategory | undefined;
};

export type GetAccountTypesQuery = {
  page: number;
  per_page: number;
  search?: string | undefined;
};

export type IAccountTypeWithMetrics = IAccountType & {
  current_total_amount: number;
  account_count: number;
  accounts: FinanceOverviewAccountItem[];
};

/**
 * Response Contracts
 */
export type CreateAccountTypeResponse = {
  account_type: IAccountType;
};

export type GetAccountTypesResponse = {
  categories: AccountTypeCategorySummary[];
  account_types: IAccountTypeWithMetrics[];
  meta: PaginationMetaDto;
};

export type GetAccountTypeDetailResponse = {
  account_type: IAccountType;
};

export type UpdateAccountTypeResponse = {
  account_type: IAccountType;
};
