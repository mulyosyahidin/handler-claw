import type { PaginationMetaDto } from "../../../../../lib/types/pagination-meta-dto.js";
import type { IApiKey } from "../../domain/entities/api-key.entity.js";

/**
 * Input Data Contracts
 */
export type CreateApiKeyRequest = {
  name: string;
};

export type UpdateApiKeyRequest = {
  name: string;
};

export type GetApiKeysQuery = {
  page: number;
  per_page: number;
  search?: string | undefined;
};

/**
 * Response Contracts
 */
export type UpdateApiKeyResponse = {
  api_key: IApiKey;
};

export type CreateApiKeyResponse = {
  api_key: IApiKey & {
    plain_key: string;
  };
};

export type GetApiKeysResponse = {
  api_keys: IApiKey[];
  meta: PaginationMetaDto;
};

export type GetApiKeyDetailResponse = {
  api_key: IApiKey;
};

export type RevokeApiKeyResponse = {
  api_key: IApiKey;
};
