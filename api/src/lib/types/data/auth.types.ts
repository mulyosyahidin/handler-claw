import type { IUser } from "../domain/index.js";

export interface LoginResponseData {
  user: IUser;
  access_token: string;
}

export interface RefreshTokenResponseData {
  access_token: string;
}
