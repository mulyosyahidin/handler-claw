import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";
import { toAccountEntity } from "../../infrastructure/mappers/account.mapper.js";
import type { GetAccountsQuery, GetAccountsResponse } from "../dtos/account.dto.js";

export class GetAccountsUseCase {
  constructor(private accountRepository: AccountRepository) {}

  async execute(userId: string, filter: GetAccountsQuery): Promise<GetAccountsResponse> {
    const pagination: PaginationType = {
      skip: (filter.page - 1) * filter.per_page,
      take: filter.per_page,
    };

    const { accounts, total } = await this.accountRepository.findAll(userId, filter, pagination);

    return {
      accounts: accounts.map(toAccountEntity),
      meta: {
        page: filter.page,
        per_page: filter.per_page,
        total,
        total_pages: Math.ceil(total / filter.per_page),
      },
    };
  }
}
