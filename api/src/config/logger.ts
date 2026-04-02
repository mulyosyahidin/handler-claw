import winston from "winston";

const { combine, timestamp, json, printf, colorize, errors } = winston.format;

const INSTANCE_NAME = process.env.INSTANCE_NAME || "local";
const IS_PRODUCTION = process.env.NODE_ENV === "production";

const devFormat = printf(({ level, message, timestamp, stack, instance }) => {
  const tag = instance ? `[${instance}]` : "";
  if (stack) {
    return `${timestamp} ${tag} ${level}: ${message}\n${stack}`;
  }
  return `${timestamp} ${tag} ${level}: ${message}`;
});

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || "info",
  defaultMeta: {
    service: "handler-api",
    instance: INSTANCE_NAME,
  },
  format: combine(
    timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
    errors({ stack: true }),
    IS_PRODUCTION ? json() : combine(colorize(), devFormat),
  ),
  transports: [new winston.transports.Console()],
});

export default logger;
