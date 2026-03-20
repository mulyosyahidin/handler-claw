import { PrismaClient } from "../lib/generated/prisma/client.js";
import { logger } from "./index.js";

function formatDuration(ms: number): string {
  if (ms < 1) return `${(ms * 1000).toFixed(0)}μs`;
  if (ms < 1000) return `${ms.toFixed(2)}ms`;
  return `${(ms / 1000).toFixed(2)}s`;
}

const prisma = new PrismaClient({
  log: [
    { emit: "event", level: "query" },
    { emit: "event", level: "error" },
    { emit: "event", level: "info" },
    { emit: "event", level: "warn" },
  ],
});

prisma.$on("query", (e) => {
  const durationStr = formatDuration(e.duration);
  logger.debug(`Prisma Query (${durationStr}): ${e.query}`, {
    duration: e.duration,
    params: e.params,
    target: e.target,
  });
});

prisma.$on("error", (e) => {
  logger.error(`Prisma Error: ${e.message}`, { target: e.target });
});

prisma.$on("warn", (e) => {
  logger.warn(`Prisma Warning: ${e.message}`, { target: e.target });
});

prisma.$on("info", (e) => {
  logger.info(`Prisma Info: ${e.message}`, { target: e.target });
});

const gracefulShutdown = async (signal: string): Promise<void> => {
  logger.info(`Shutting down Prisma client (${signal})...`);
  await prisma.$disconnect();
  process.exit(0);
};

process.on("SIGINT", () => gracefulShutdown("SIGINT"));
process.on("SIGTERM", () => gracefulShutdown("SIGTERM"));

export default prisma;
