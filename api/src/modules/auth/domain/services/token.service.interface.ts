export interface TokenService {
  createAccessToken(payload: { userId: string; email: string }): Promise<string>;
  refreshAccessToken(oldToken: string): Promise<string>;
}
