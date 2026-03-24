import type { IWhatsappLog } from "../domain/index.js";

export interface CreateWhatsappLogResponseData {
  whatsapp_log: IWhatsappLog;
}

export interface GetWhatsappLogsResponseData {
  whatsapp_logs: IWhatsappLog[];
  next_cursor: number | null;
}

export interface GetWhatsappLogsSummaryResponseData {
  total: number;
  by_device: Record<string, number>;
  by_message_type: Record<string, number>;
  by_chat_type: { group: number; personal: number };
}
