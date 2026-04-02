import type { ApiKeyStatus } from "../../../../../lib/generated/prisma/enums.js";

export type IApiKey = {
  id: string;
  user_id: string;
  key_preview: string;
  key_full: string;
  name: string;
  status: ApiKeyStatus;
  created_at: Date;
  updated_at: Date;
  deleted_at: Date | null;
};
