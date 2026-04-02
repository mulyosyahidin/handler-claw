import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";
import { toAccountEntity } from "../../infrastructure/mappers/account.mapper.js";
import type { GetAccountDetailResponse } from "../dtos/account.dto.js";

export class GetAccountDetailUseCase {
  constructor(private accountRepository: AccountRepository) {}

  async execute(userId: string, id: string): Promise<GetAccountDetailResponse> {
    const account = await this.accountRepository.findById(userId, id);

    if (!account) {
      throw new Error("Akun tidak ditemukan");
    }

    return {
      account: toAccountEntity(account),
    };
  }
}
