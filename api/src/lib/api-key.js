"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateApiKey = generateApiKey;
exports.hashApiKey = hashApiKey;
exports.getApiKeyPreview = getApiKeyPreview;
var node_crypto_1 = require("node:crypto");
/**
 * Generate a random API key in the format hc-<16 random chars>
 */
function generateApiKey() {
  // 16 random hex characters (8 bytes)
  var randomChars = node_crypto_1.default.randomBytes(8).toString("hex");
  return "hc-".concat(randomChars);
}
/**
 * Hash an API key using SHA-256
 */
function hashApiKey(key) {
  return node_crypto_1.default.createHash("sha256").update(key).digest("base64");
}
/**
 * Get a preview of the API key in the format hc-***abcd
 */
function getApiKeyPreview(key) {
  if (key.length < 7) return key;
  var lastFour = key.slice(-4);
  return "hc-***".concat(lastFour);
}
