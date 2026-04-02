import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";

export class DeleteAccountTypeUseCase {
  constructor(private accountTypeRepository: AccountTypeRepository) {}

  async execute(_userId: string, id: string): Promise<void> {
    await this.accountTypeRepository.softDelete(id);
  }
}
