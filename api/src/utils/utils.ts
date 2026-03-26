import type { Prisma } from "../lib/generated/prisma/client.js";

/**
 * Mengekstrak header spesifik dari objek Headers Web API atau Record standar.
 * @param headers - Objek header yang akan diperiksa.
 * @returns Objek yang hanya berisi header yang ditentukan dalam daftar 'important'.
 */
export function extractImportantHeaders(headers: Headers | Record<string, any>) {
  const important = ["user-agent", "content-type", "x-forwarded-for"];
  const result: Record<string, string> = {};

  // Proteksi jika headers null atau undefined
  if (!headers) return result;

  for (const key of important) {
    let value: any = null;

    // 1. Cek jika menggunakan Web API Headers (.get())
    if (typeof (headers as Headers).get === "function") {
      value = (headers as Headers).get(key);
    }
    // 2. Cek jika menggunakan plain object (Express/Node)
    else {
      const rawHeaders = headers as Record<string, any>;
      // Cari dengan kunci asli atau versi huruf kecil
      value = rawHeaders[key] ?? rawHeaders[key.toLowerCase()];
    }

    // Hanya masukkan ke result jika value benar-benar ada
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
