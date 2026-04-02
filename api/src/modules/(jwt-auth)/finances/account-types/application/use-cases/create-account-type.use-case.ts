import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";
import { toAccountTypeEntity } from "../../infrastructure/mappers/account-type.mapper.js";
import type {
  CreateAccountTypeRequest,
  CreateAccountTypeResponse,
} from "../dtos/account-type.dto.js";

export class CreateAccountTypeUseCase {
  constructor(private accountTypeRepository: AccountTypeRepository) {}

  async execute(
    userId: string,
    input: CreateAccountTypeRequest,
  ): Promise<CreateAccountTypeResponse> {
    const accountType = await this.accountTypeRepository.create(userId, {
      name: input.name,
      category: input.category,
    });

    return {
      account_type: toAccountTypeEntity(accountType),
    };
  }
}
