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

export function getDateRangeFromType(
  date_type: string,
  start_date?: string,
  end_date?: string
): { gte?: Date; lte?: Date } | undefined {
  let filterStartDate: Date | undefined;
  let filterEndDate: Date | undefined;

  const now = new Date();

  switch (date_type) {
    case "daily":
      filterStartDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
      filterEndDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59, 999);
      break;
    case "weekly":
      const day = now.getDay() || 7;
      const monday = new Date(now);
      monday.setDate(now.getDate() - day + 1);
      monday.setHours(0, 0, 0, 0);

      const sunday = new Date(monday);
      sunday.setDate(monday.getDate() + 6);
      sunday.setHours(23, 59, 59, 999);

      filterStartDate = monday;
      filterEndDate = sunday;
      break;
    case "monthly":
      filterStartDate = new Date(now.getFullYear(), now.getMonth(), 1, 0, 0, 0, 0);
      filterEndDate = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59, 999);
      break;
    case "yearly":
      filterStartDate = new Date(now.getFullYear(), 0, 1, 0, 0, 0, 0);
      filterEndDate = new Date(now.getFullYear(), 11, 31, 23, 59, 59, 999);
      break;
    case "custom":
      if (start_date) {
        const sd = new Date(start_date);
        filterStartDate = new Date(sd.getFullYear(), sd.getMonth(), sd.getDate(), 0, 0, 0, 0);
      }
      if (end_date) {
        const ed = new Date(end_date);
        filterEndDate = new Date(ed.getFullYear(), ed.getMonth(), ed.getDate(), 23, 59, 59, 999);
      }
      break;
  }

  if (filterStartDate || filterEndDate) {
    return {
      ...(filterStartDate && { gte: filterStartDate }),
      ...(filterEndDate && { lte: filterEndDate }),
    };
  }
  return undefined;
}
