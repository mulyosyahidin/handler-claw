import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";
import { toAccountSnapshotEntity } from "../../infrastructure/mappers/account-snapshot.mapper.js";
import type {
  UpdateAccountSnapshotRequest,
  UpdateAccountSnapshotResponse,
} from "../dtos/account-snapshot.dto.js";

export class UpdateAccountSnapshotUseCase {
  constructor(private accountSnapshotRepository: AccountSnapshotRepository) {}

  async execute(
    _userId: string,
    id: string,
    input: UpdateAccountSnapshotRequest,
  ): Promise<UpdateAccountSnapshotResponse> {
    // Clean undefined values for exactOptionalPropertyTypes
    const updateData: any = {};
    if (input.amount !== undefined) updateData.amount = input.amount;
    if (input.date !== undefined) updateData.date = input.date;
    if (input.note !== undefined) updateData.note = input.note;

    const snapshot = await this.accountSnapshotRepository.update(id, updateData);

    return {
      snapshot: toAccountSnapshotEntity(snapshot),
    };
  }
}
