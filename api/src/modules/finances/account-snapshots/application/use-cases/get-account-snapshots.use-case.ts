import type { PaginationType } from "../../../../../lib/types/pagination.type.js";
import type { AccountSnapshotRepository } from "../../domain/repositories/account-snapshot.repository.interface.js";
import { toAccountSnapshotEntity } from "../../infrastructure/mappers/account-snapshot.mapper.js";
import type {
  GetAccountSnapshotsQuery,
  GetAccountSnapshotsResponse,
} from "../dtos/account-snapshot.dto.js";

export class GetAccountSnapshotsUseCase {
  constructor(private accountSnapshotRepository: AccountSnapshotRepository) {}

  async execute(
    userId: string,
    filter: GetAccountSnapshotsQuery,
  ): Promise<GetAccountSnapshotsResponse> {
    const pagination: PaginationType = {
      skip: (filter.page - 1) * filter.per_page,
      take: filter.per_page,
    };

    const { snapshots, total } = await this.accountSnapshotRepository.findAll(
      userId,
      filter,
      pagination,
    );

    return {
      snapshots: snapshots.map(toAccountSnapshotEntity),
      meta: {
        page: filter.page,
        per_page: filter.per_page,
        total,
        total_pages: Math.ceil(total / filter.per_page),
      },
    };
  }
}
