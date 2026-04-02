import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";
import { toAccountTypeEntity } from "../../infrastructure/mappers/account-type.mapper.js";
import type { GetAccountTypeDetailResponse } from "../dtos/account-type.dto.js";

export class GetAccountTypeDetailUseCase {
  constructor(private accountTypeRepository: AccountTypeRepository) {}

  async execute(userId: string, id: string): Promise<GetAccountTypeDetailResponse> {
    const accountType = await this.accountTypeRepository.findById(userId, id);

    // If it reached here, controller already validated existence
    if (!accountType) {
      throw new Error("Unexpected error: Account type not found after controller validation");
    }

    return {
      account_type: toAccountTypeEntity(accountType),
    };
  }
}
