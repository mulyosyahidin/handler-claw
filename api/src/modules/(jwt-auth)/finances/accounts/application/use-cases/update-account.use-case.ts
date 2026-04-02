import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";
import { toAccountEntity } from "../../infrastructure/mappers/account.mapper.js";
import type { UpdateAccountRequest, UpdateAccountResponse } from "../dtos/account.dto.js";

export class UpdateAccountUseCase {
  constructor(private accountRepository: AccountRepository) {}

  async execute(
    _userId: string,
    id: string,
    input: UpdateAccountRequest,
  ): Promise<UpdateAccountResponse> {
    const updateData: any = {};
    if (input.name !== undefined) updateData.name = input.name;
    if (input.account_type_id !== undefined) updateData.account_type_id = input.account_type_id;

    const account = await this.accountRepository.update(id, updateData);

    return {
      account: toAccountEntity(account),
    };
  }
}
