import type { PaginationType } from "../../../../../../lib/types/pagination.type.js";
import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";
import { toAccountTypeWithMetricsEntity } from "../../infrastructure/mappers/account-type.mapper.js";
import type { GetAccountTypesQuery, GetAccountTypesResponse } from "../dtos/account-type.dto.js";

export class GetAccountTypesUseCase {
  constructor(private accountTypeRepository: AccountTypeRepository) {}

  async execute(userId: string, filter: GetAccountTypesQuery): Promise<GetAccountTypesResponse> {
    const pagination: PaginationType = {
      skip: (filter.page - 1) * filter.per_page,
      take: filter.per_page,
    };

    const { accountTypes, total, categories } = await this.accountTypeRepository.findAll(
      userId,
      filter,
      pagination,
    );

    return {
      categories,
      account_types: accountTypes.map(toAccountTypeWithMetricsEntity),
      meta: {
        page: filter.page,
        per_page: filter.per_page,
        total,
        total_pages: Math.ceil(total / filter.per_page),
      },
    };
  }
}
