import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";
import { toAccountEntity } from "../../infrastructure/mappers/account.mapper.js";
import type { CreateAccountRequest, CreateAccountResponse } from "../dtos/account.dto.js";

export class CreateAccountUseCase {
  constructor(private accountRepository: AccountRepository) {}

  async execute(userId: string, input: CreateAccountRequest): Promise<CreateAccountResponse> {
    const account = await this.accountRepository.create(userId, {
      name: input.name,
      account_type_id: input.account_type_id,
    });

    return {
      account: toAccountEntity(account),
    };
  }
}
