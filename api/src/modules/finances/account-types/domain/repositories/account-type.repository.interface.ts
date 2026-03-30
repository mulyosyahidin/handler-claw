import { type AccountType } from "../../../../../lib/generated/prisma/client.js";
import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type {
  CreateAccountTypeData,
  GetAccountTypesQuery,
} from "../../application/dtos/account-type.dto.js";

export type UpdateAccountTypeData = Partial<CreateAccountTypeData>;

export interface AccountTypeRepository {
  create(userId: string, data: CreateAccountTypeData): Promise<AccountType>;
  findAll(
    userId: string,
    filter: GetAccountTypesQuery,
    pagination: PaginationType,
  ): Promise<{ accountTypes: AccountType[]; total: number }>;
  findById(userId: string, id: string): Promise<AccountType | null>;
  findByName(userId: string, name: string): Promise<AccountType | null>;
  update(id: string, data: UpdateAccountTypeData): Promise<AccountType>;
  softDelete(id: string): Promise<AccountType>;
}
