import crypto from "node:crypto";

/**
 * Generate a random API key in the format hc-<16 random chars>
 */
export function generateApiKey(): string {
  // 16 random hex characters (8 bytes)
  const randomChars = crypto.randomBytes(8).toString("hex");
  return `hc-${randomChars}`;
}

/**
 * Hash an API key using SHA-256
 */
export function hashApiKey(key: string): string {
  return crypto.createHash("sha256").update(key).digest("base64");
}

/**
 * Get a preview of the API key in the format hc-***abcd
 */
export function getApiKeyPreview(key: string): string {
  if (key.length < 7) return key;
  const lastFour = key.slice(-4);
  return `hc-***${lastFour}`;
}
