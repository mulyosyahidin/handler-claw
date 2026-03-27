import type { User } from "../../domain/entities/user.entity.js";

/**
 * Request Contracts
 */
export type LoginRequest = {
  email: string;
  password: string;
};

export type RefreshTokenRequest = {
  refresh_token: string;
};

export type UpdateProfileRequest = {
  name: string;
  email: string;
};

export type UpdatePasswordRequest = {
  current_password: string;
  new_password: string;
  confirm_new_password: string;
};

/**
 * Response Contracts
 */
export type LoginResponse = {
  user: User;
  access_token: string;
};

export type RefreshTokenResponse = {
  access_token: string;
};

export type GetMeResponse = {
  user: User;
};

export type UpdateProfileResponse = {
  user: User;
};
