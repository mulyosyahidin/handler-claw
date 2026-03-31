import { type AccountType } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  FindAllAccountTypesResult,
  CreateAccountTypeData,
  GetAccountTypesQuery,
  UpdateAccountTypeData,
} from "../../application/dtos/account-type.dto.js";

export interface AccountTypeRepository {
  create(userId: string, data: CreateAccountTypeData): Promise<AccountType>;
  findAll(
    userId: string,
    filter: GetAccountTypesQuery,
    pagination: PaginationType,
  ): Promise<FindAllAccountTypesResult>;
  findById(userId: string, id: string): Promise<AccountType | null>;
  findByName(userId: string, name: string): Promise<AccountType | null>;
  update(id: string, data: UpdateAccountTypeData): Promise<AccountType>;
  softDelete(id: string): Promise<AccountType>;
}
