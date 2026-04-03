import fs from "node:fs/promises";
import path from "node:path";

export class WebhookLoggerService {
  private logDir: string;
  private logFile: string;

  constructor() {
    // In production, logs are in /app/logs
    // In development, they are in the project root/logs
    this.logDir =
      process.env.NODE_ENV === "production" ? "/app/logs" : path.join(process.cwd(), "logs");

    this.logFile = path.join(this.logDir, "webhooks.log");
  }

  async log(headers: any, body: any): Promise<void> {
    try {
      // Ensure directory exists
      await fs.mkdir(this.logDir, { recursive: true });

      const entry = {
        timestamp: new Date().toISOString(),
        headers,
        body,
      };

      await fs.appendFile(this.logFile, JSON.stringify(entry) + "\n", "utf8");
    } catch (error) {
      console.error("WebhookLoggerService::log() Error:", error);
    }
  }
}
