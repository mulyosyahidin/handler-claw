import type { IUser } from "../../domain/entities/user.entity.js";

/**
 * Input Data Contracts
 */
export type LoginRequest = {
  email: string;
  password: string;
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
  user: IUser;
  access_token: string;
};

export type RefreshTokenResponse = {
  access_token: string;
};

export type GetMeResponse = {
  user: IUser;
};

export type UpdateProfileResponse = {
  user: IUser;
};

/**
 * Repository Data Contracts
 */
export type UserFilter = {
  id?: string;
  email?: string;
  name?: string;
  NOT?: UserFilter;
};

export type UpdateUserData = {
  name?: string;
  email?: string;
  password?: string;
  lastLoginAt?: Date;
};
