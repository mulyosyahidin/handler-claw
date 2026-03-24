import type { IWhatsappLog } from "../domain/index.js";

interface FilterInfo {
  date_type: string;
  start?: string | undefined;
  end?: string | undefined;
  filtered: {
    date_start?: string | undefined;
    date_end?: string | undefined;
  };
}

export interface CreateWhatsappLogResponseData {
  whatsapp_log: IWhatsappLog;
}

export interface GetWhatsappLogsResponseData {
  filter: FilterInfo;
  whatsapp_logs: IWhatsappLog[];
  next_cursor: number | null;
}

export interface WhatsappLogSummarySenderGroup {
  sender_name: string | null;
  sender: string;
  messages: IWhatsappLog[];
}

export interface GetWhatsappLogsSummaryResponseData {
  filter: FilterInfo;
  total: number;
  by_device: Record<string, number>;
  by_message_type: Record<string, number>;
  by_chat_type: { group: number; personal: number };
  messages: Record<string, WhatsappLogSummarySenderGroup[]>;
}
