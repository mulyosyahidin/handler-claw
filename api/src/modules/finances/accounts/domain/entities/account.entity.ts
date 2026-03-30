import type { IAccountSnapshot } from "../../../account-snapshots/domain/entities/account-snapshot.entity.js";

export type IAccount = {
  id: string;
  user_id: string;
  name: string;
  account_type_id: string;
  created_at: Date;
  updated_at: Date;
  balances?: IAccountSnapshot[] | undefined;
};
