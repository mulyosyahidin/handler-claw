import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";
import { toAccountSnapshotEntity } from "../../infrastructure/mappers/account-snapshot.mapper.js";
import type { GetAccountSnapshotDetailResponse } from "../dtos/account-snapshot.dto.js";

export class GetAccountSnapshotDetailUseCase {
  constructor(private accountSnapshotRepository: AccountSnapshotRepository) {}

  async execute(userId: string, id: string): Promise<GetAccountSnapshotDetailResponse> {
    const snapshot = await this.accountSnapshotRepository.findById(userId, id);

    if (!snapshot) {
      throw new Error("Snapshot saldo tidak ditemukan");
    }

    return {
      snapshot: toAccountSnapshotEntity(snapshot),
    };
  }
}
