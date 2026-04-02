import { SignJWT, jwtVerify, errors, type JWTPayload } from "jose";

const JWT_SECRET = new TextEncoder().encode(process.env.JWT_SECRET || "secret");

const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1h";

export interface TokenPayload extends JWTPayload {
  userId: string;
  email: string;
}

export async function createAccessToken(payload: TokenPayload): Promise<string> {
  const token = await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime(JWT_EXPIRES_IN)
    .sign(JWT_SECRET);

  return token;
}

export async function verifyAccessToken(token: string): Promise<TokenPayload> {
  const { payload } = await jwtVerify(token, JWT_SECRET);
  return payload as TokenPayload;
}

export async function refreshAccessToken(oldToken: string): Promise<string> {
  let payload: TokenPayload;

  try {
    const result = await jwtVerify(oldToken, JWT_SECRET);

    payload = result.payload as TokenPayload;
  } catch (err) {
    if (err instanceof errors.JWTExpired) {
      payload = err.payload as TokenPayload;
    } else {
      throw new Error("INVALID_TOKEN", { cause: err });
    }
  }

  return createAccessToken({
    userId: payload.userId,
    email: payload.email,
  });
}
