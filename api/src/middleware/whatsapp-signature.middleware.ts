import crypto from "crypto";
import type { Request, Response, NextFunction } from "express";
import { createErrorResponse } from "../lib/types/response.js";

/**
 * Middleware to verify WhatsApp/WAG webhook signatures.
 * Expects the signature in 'x-hub-signature-256' header.
 * Uses WAG_SECRET from environment variables.
 */
export function whatsappSignatureMiddleware(req: Request, res: Response, next: NextFunction): void {
  const signature = req.headers["x-hub-signature-256"];
  const secret = process.env.WAG_SECRET;

  if (!secret) {
    console.error("WAG_SECRET is not defined in environment variables");
    res.status(500).json(
      createErrorResponse("Internal Server Error", {
        config: "WAG_SECRET is not configured on the server.",
      }),
    );
    return;
  }

  if (!signature || typeof signature !== "string") {
    res.status(401).json(
      createErrorResponse("Unauthorized", {
        signature: "Signature is missing or invalid.",
      }),
    );
    return;
  }

  if (!req.rawBody) {
    res.status(400).json(
      createErrorResponse("Bad Request", {
        body: "Raw body is missing for signature verification.",
      }),
    );
    return;
  }

  try {
    const expectedSignature = crypto.createHmac("sha256", secret).update(req.rawBody).digest("hex");

    const receivedSignature = signature.replace("sha256=", "");

    const isMatch = crypto.timingSafeEqual(
      Buffer.from(expectedSignature, "hex"),
      Buffer.from(receivedSignature, "hex"),
    );

    if (!isMatch) {
      res.status(401).json(
        createErrorResponse("Unauthorized", {
          signature: "Signature mismatch.",
        }),
      );
      return;
    }

    next();
  } catch (error) {
    console.error("Signature verification error:", error);
    res.status(401).json(
      createErrorResponse("Unauthorized", {
        signature: "Error verifying signature.",
      }),
    );
  }
}
