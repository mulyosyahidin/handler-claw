import type { WhatsappLog } from "../../domain/entities/whatsapp-log.entity.js";
import type { DateFilterType } from "../../../../utils/date-filter.js";

/**
 * Shared Helper Types
 */
export type WhatsappLogFilter = {
  date_type: DateFilterType | string;
  start?: string | undefined;
  end?: string | undefined;
  filtered: {
    date_start?: string | undefined;
    date_end?: string | undefined;
  };
};


/**
 * Response Contracts
 */
export type CreateWhatsappLogResponse = {
  whatsapp_log: WhatsappLog;
};

export type GetWhatsappLogsResponse = {
  filter: WhatsappLogFilter;
  whatsapp_logs: WhatsappLog[];
  next_cursor: number | null;
};

export type WhatsappLogSenderGroup = {
  sender_name: string | null;
  sender: string;
  messages: WhatsappLog[];
};

export type GetWhatsappLogsSummaryResponse = {
  filter: WhatsappLogFilter;
  total: number;
  by_device: Record<string, number>;
  by_message_type: Record<string, number>;
  by_chat_type: { group: number; personal: number };
  messages: Record<string, WhatsappLogSenderGroup[]>;
};
