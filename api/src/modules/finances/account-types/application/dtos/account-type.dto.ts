import type { PaginationMetaDto } from "../../../../../lib/types/pagination-meta-dto.js";
import type { IAccountType } from "../../domain/entities/account-type.entity.js";
import type { AccountCategory } from "../../../../../lib/generated/prisma/enums.js";

/**
 * Input Data Contracts
 */
export type CreateAccountTypeData = {
  name: string;
  category: AccountCategory;
};

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

/**
 * Response Contracts
 */
export type CreateAccountTypeResponse = {
  account_type: IAccountType;
};

export type GetAccountTypesResponse = {
  account_types: IAccountType[];
  meta: PaginationMetaDto;
};

export type GetAccountTypeDetailResponse = {
  account_type: IAccountType;
};

export type UpdateAccountTypeResponse = {
  account_type: IAccountType;
};
