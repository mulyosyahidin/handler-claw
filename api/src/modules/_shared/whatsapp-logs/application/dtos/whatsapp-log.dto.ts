import type { PaginationMetaDto } from "../../../../../lib/types/pagination-meta-dto.js";
import type { IWhatsappLog } from "../../domain/entities/whatsapp-log.entity.js";

/**
 * Input Data Contracts
 */
export type CreateWhatsappLogRequest = {
  quick: boolean;
  device: string;
  mode: string;
  sender: string;
  senderlid?: string | undefined;
  pengirim?: string | undefined;
  name?: string | undefined;
  isgroup: boolean;
  member?: string | undefined;
  memberlid?: string | undefined;
  message?: string | undefined;
  pesan?: string | undefined;
  text?: string | undefined;
  type: string;
  isforwarded: boolean;
  inboxid: number;
  extension?: string | undefined;
  filename?: string | undefined;
  location?: string | undefined;
  url?: string | undefined;
  pollname?: string | undefined;
  choices: any[];
  timestamp: bigint;
};

export type GetWhatsappLogsQuery = {
  page: number;
  per_page: number;
  search?: string | undefined;
  is_group?: boolean | undefined;
};

export type GetWhatsappLogsSummaryQuery = {
  date_type:
    | "today"
    | "this_week"
    | "this_month"
    | "this_year"
    | "7_days"
    | "30_days"
    | "1_year"
    | "all"
    | "custom";
  start?: string;
  end?: string;
};

export type CreateWhatsappLogData = {
  device: string;
  mode: string;
  userId: string | null;

  sender: string;
  senderLid: string | null;
  senderName: string | null;

  isGroup: boolean;
  groupId: string | null;

  memberPhone: string | null;
  memberLid: string | null;

  messageText: string;
  messageType: string;

  isForwarded: boolean;
  isQuick: boolean;

  inboxId: number;

  extension: string | null;
  filename: string | null;
  url: string | null;
  location: string | null;

  pollName: string | null;
  pollChoices: string[];

  waTimestamp: bigint;
};

/**
 * Filter Contracts
 */
export type WhatsappLogFilter = {
  search?: string | undefined;
  isGroup?: boolean | undefined;
  userId?: string | undefined;
};

/**
 * Response Contracts
 */
export type CreateWhatsappLogResponse = {
  whatsapp_log: IWhatsappLog;
};

export type GetWhatsappLogsResponse = {
  whatsapp_logs: IWhatsappLog[];
  meta: PaginationMetaDto;
};

export type WhatsappSummaryEntry = {
  label: string;
  total_messages: number;
  total_group: number;
  total_personal: number;
};

export type GetWhatsappLogsSummaryResponse = {
  filter: {
    date_type: string;
    start?: string | undefined;
    end?: string | undefined;
    filtered?: {
      date_start?: string | undefined;
      date_end?: string | undefined;
    };
  };
  summary: WhatsappSummaryEntry[];
  grand_total: {
    total_messages: number;
    total_group: number;
    total_personal: number;
  };
};
