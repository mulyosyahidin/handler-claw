import type { AccountCategory } from "../../../../../../lib/generated/prisma/enums.js";

export type IAccountType = {
  id: string;
  user_id: string;
  name: string;
  category: AccountCategory;
  created_at: Date;
  updated_at: Date;
};
