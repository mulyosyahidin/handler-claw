import type { UserDevicePlatform } from "../../../../lib/generated/prisma/enums.js";
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

export type UpdateAvatarRequest = {
  avatar_url: string;
};

export type GoogleLoginRequest = {
  id_token: string;
  device_id?: string | undefined;
  device_brand?: string | undefined;
  device_model?: string | undefined;
  os_build_id?: string | undefined;
  os_version?: string | undefined;
  fcm_token?: string | undefined;
  platform?: UserDevicePlatform | undefined;
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

export type UpdateAvatarResponse = {
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
  name?: string | undefined;
  email?: string | undefined;
  password?: string | undefined;
  lastLoginAt?: Date | undefined;
  avatarUrl?: string | undefined;
};

export type CreateUserData = {
  email: string;
  name: string;
  driver: "EMAIL" | "GOOGLE";
  password?: string | undefined;
  avatarUrl?: string | undefined;
};
