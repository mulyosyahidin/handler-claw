import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";

export class DeleteAccountSnapshotUseCase {
  constructor(private accountSnapshotRepository: AccountSnapshotRepository) {}

  async execute(_userId: string, id: string): Promise<void> {
    await this.accountSnapshotRepository.softDelete(id);
  }
}
