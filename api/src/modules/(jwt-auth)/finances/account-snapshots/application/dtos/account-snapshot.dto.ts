import type { PaginationMetaDto } from "../../../../../../lib/types/pagination-meta-dto.js";
import type { IAccountSnapshot } from "../../domain/entities/account-snapshot.entity.js";

/**
 * Input Data Contracts
 */
export type CreateAccountSnapshotData = {
  account_id: string;
  amount: number;
  date: Date;
  note?: string | null;
};

export type CreateAccountSnapshotRequest = CreateAccountSnapshotData;

export type UpdateAccountSnapshotRequest = {
  amount?: number;
  date?: Date;
  note?: string | null;
};

export type GetAccountSnapshotsQuery = {
  page: number;
  per_page: number;
  account_id?: string;
  start_date?: Date;
  end_date?: Date;
};

/**
 * Response Contracts
 */
export type CreateAccountSnapshotResponse = {
  snapshot: IAccountSnapshot;
};

export type GetAccountSnapshotsResponse = {
  snapshots: IAccountSnapshot[];
  meta: PaginationMetaDto;
};

export type GetAccountSnapshotDetailResponse = {
  snapshot: IAccountSnapshot;
};

export type UpdateAccountSnapshotResponse = {
  snapshot: IAccountSnapshot;
};
