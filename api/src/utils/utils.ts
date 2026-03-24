export function extractImportantHeaders(headers: Headers | Record<string, any>) {
  const important = ["user-agent", "content-type", "x-api-key", "x-forwarded-for"];

  const result: Record<string, string> = {};

  for (const key of important) {
    let value: any;

    // Check if `headers` is a Web API Headers object with a .get() method
    if (headers && typeof headers.get === "function") {
      value = headers.get(key);
    } else if (headers) {
      // Otherwise, assume it's a plain object (e.g. Express req.headers)
      // Express headers are typically lowercased
      const rawHeaders = headers as Record<string, any>;
      value = rawHeaders[key] || rawHeaders[key.toLowerCase()];
    }

    if (value) {
      result[key] = Array.isArray(value) ? value.join(", ") : String(value);
    }
  }

  return result;
}

export function formatDateToLocalISO(d: Date): string {
  const pad = (n: number) => n.toString().padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}
