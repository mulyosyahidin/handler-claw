import type { ApiKey } from "../../../../../lib/generated/prisma/client.js";
import type { IApiKey } from "../../domain/entities/api-key.entity.js";

export function toApiKeyEntity(data: ApiKey): IApiKey {
  return {
    id: data.id,
    user_id: data.userId,
    name: data.name,
    key_preview: data.keyPreview,
    key_full: data.keyFull,
    status: data.status,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
    deleted_at: data.deletedAt,
  };
}
