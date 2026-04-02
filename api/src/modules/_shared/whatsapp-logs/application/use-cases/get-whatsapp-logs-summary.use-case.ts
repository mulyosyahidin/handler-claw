import { getPrayerDateFilter } from "../../../../../utils/date-filter.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import type {
  GetWhatsappLogsSummaryQuery,
  GetWhatsappLogsSummaryResponse,
  WhatsappSummaryEntry,
} from "../dtos/whatsapp-log.dto.js";

export class GetWhatsappLogsSummaryUseCase {
  constructor(private repository: WhatsappLogRepository) {}

  async execute(
    userId: string | null,
    query: GetWhatsappLogsSummaryQuery,
  ): Promise<GetWhatsappLogsSummaryResponse> {
    const { date_type, start, end } = query;
    const { filter: dateFilter, date_start, date_end } = getPrayerDateFilter(date_type, start, end);

    const rows = await this.repository.findSummary(userId, dateFilter);

    const grouped = new Map<string, WhatsappSummaryEntry>();

    if (date_start && date_end) {
      const [y1, m1, d1] = this.parseYMD(date_start);
      const [y2, m2, d2] = this.parseYMD(date_end);

      const cur = new Date(Date.UTC(y1, m1 - 1, d1));
      const endObj = new Date(Date.UTC(y2, m2 - 1, d2));

      while (cur <= endObj) {
        const label = this.toISODate(cur);
        grouped.set(label, { label, total_messages: 0, total_group: 0, total_personal: 0 });
        cur.setUTCDate(cur.getUTCDate() + 1);
      }
    }

    let grandMessages = 0;
    let grandGroup = 0;
    let grandPersonal = 0;

    for (const row of rows) {
      const label = this.toISODate(new Date(row.date));
      const count = Number(row.count);

      if (!grouped.has(label)) {
        grouped.set(label, { label, total_messages: 0, total_group: 0, total_personal: 0 });
      }

      const entry = grouped.get(label)!;
      entry.total_messages += count;
      grandMessages += count;

      if (row.is_group) {
        entry.total_group += count;
        grandGroup += count;
      } else {
        entry.total_personal += count;
        grandPersonal += count;
      }
    }

    const summary = Array.from(grouped.values()).sort((a, b) => a.label.localeCompare(b.label));

    return {
      filter: {
        date_type,
        ...(date_type === "custom" ? { start, end } : {}),
        filtered: { date_start, date_end },
      },
      summary,
      grand_total: {
        total_messages: grandMessages,
        total_group: grandGroup,
        total_personal: grandPersonal,
      },
    };
  }

  private toISODate(d: Date): string {
    const pad = (n: number) => n.toString().padStart(2, "0");
    return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
  }

  private parseYMD(dateStr: string): [number, number, number] {
    const parts = dateStr.split("-");
    const y = Number(parts[0]);
    const m = Number(parts[1]);
    const d = Number(parts[2]);
    return [y, m, d];
  }
}
