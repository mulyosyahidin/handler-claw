export interface HealthRepository {
  checkDatabaseConnection(): Promise<"connected" | "disconnected">;
}
