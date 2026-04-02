export type IAccountSnapshot = {
  id: string;
  account_id: string;
  amount: number;
  date: Date;
  note: string | null;
  created_at: Date;
  updated_at: Date;
};
