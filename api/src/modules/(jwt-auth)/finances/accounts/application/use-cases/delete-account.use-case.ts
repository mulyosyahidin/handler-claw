import type { AccountRepository } from "../../domain/repositories/account.repository.interface.js";

export class DeleteAccountUseCase {
  constructor(private accountRepository: AccountRepository) {}

  async execute(_userId: string, id: string): Promise<void> {
    await this.accountRepository.softDelete(id);
  }
}
