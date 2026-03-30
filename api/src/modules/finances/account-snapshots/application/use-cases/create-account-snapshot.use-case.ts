import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";
import { toAccountSnapshotEntity } from "../../infrastructure/mappers/account-snapshot.mapper.js";
import type {
  CreateAccountSnapshotRequest,
  CreateAccountSnapshotResponse,
} from "../dtos/account-snapshot.dto.js";

export class CreateAccountSnapshotUseCase {
  constructor(private accountSnapshotRepository: AccountSnapshotRepository) {}

  async execute(
    _userId: string,
    input: CreateAccountSnapshotRequest,
  ): Promise<CreateAccountSnapshotResponse> {
    const snapshot = await this.accountSnapshotRepository.create({
      account_id: input.account_id,
      amount: input.amount,
      date: input.date,
      note: input.note,
    });

    return {
      snapshot: toAccountSnapshotEntity(snapshot),
    };
  }
}
