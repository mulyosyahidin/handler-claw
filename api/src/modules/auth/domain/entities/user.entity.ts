import type { UserDriver } from "../../../../lib/generated/prisma/enums.js";

export type IUser = {
  id: string;
  email: string;
  name: string;
  last_login_at: Date | null;
  avatar_url: string | null;
  driver: UserDriver;
  created_at: Date;
  updated_at: Date;
};
