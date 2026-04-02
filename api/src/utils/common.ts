import type { Prisma } from "../lib/generated/prisma/client.js";

export function extractImportantHeaders(headers: Headers | Record<string, any>) {
  const important = ["user-agent", "content-type", "x-forwarded-for"];
  const result: Record<string, string> = {};
  if (!headers) return result;

  for (const key of important) {
    let value: any = null;

    if (typeof (headers as Headers).get === "function") {
      value = (headers as Headers).get(key);
    } else {
      const rawHeaders = headers as Record<string, any>;
      value = rawHeaders[key] ?? rawHeaders[key.toLowerCase()];
    }

    if (value !== null && value !== undefined) {
      result[key] = Array.isArray(value) ? value.join(", ") : String(value);
    }
  }

  return result;
}

export function formatDateToLocalISO(d: Date): string {
  const pad = (n: number) => n.toString().padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

export function toFcmData(data: Prisma.InputJsonValue | null | undefined): Record<string, string> {
  if (!data || typeof data !== "object" || Array.isArray(data)) {
    return {};
  }

  const result: Record<string, string> = {};

  for (const [key, value] of Object.entries(data)) {
    result[key] = typeof value === "string" ? value : JSON.stringify(value);
  }

  return result;
}
