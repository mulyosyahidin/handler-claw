import type { IReminderHook } from "../domain/index.js";

export interface CreateReminderHookResponseData {
  reminder_hook: IReminderHook;
}

export interface GetReminderHooksResponseData {
  reminder_hooks: IReminderHook[];
  meta: {
    page: number;
    per_page: number;
    total: number;
    total_pages: number;
  };
}

export interface ReminderHooksSummaryData {
  total: number;
  status_counts: {
    received: number;
    processing: number;
    processed: number;
    failed: number;
  };
}
