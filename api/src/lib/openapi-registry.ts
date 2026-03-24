import { OpenAPIRegistry, OpenApiGeneratorV3 } from "@asteasolutions/zod-to-openapi";
import { loginSchema, logPrayerSchema, refreshTokenSchema } from "./schemas/index.js";
import { z } from "zod";
import type { OpenAPIObject } from '@asteasolutions/zod-to-openapi/dist/types.js';

export const registry = new OpenAPIRegistry();

// Define Security Scheme
const bearerAuth = registry.registerComponent("securitySchemes", "bearerAuth", {
  type: "http",
  scheme: "bearer",
  bearerFormat: "JWT",
});

// REGISTER AUTH ROUTES
registry.registerPath({
  method: "post",
  path: "/api/auth/login",
  summary: "User Login",
  tags: ["Auth"],
  request: {
    body: {
      content: {
        "application/json": {
          schema: loginSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: "Login successful",
    },
    401: {
      description: "Unauthorized",
    },
  },
});

registry.registerPath({
  method: "post",
  path: "/api/auth/refresh-access-token",
  summary: "Refresh Access Token",
  description: "Renew access token using the old token",
  tags: ["Auth"],
  request: {
    body: {
      content: {
        "application/json": {
          schema: refreshTokenSchema,
        },
      },
    },
  },
  responses: {
    200: {
      description: "Token successfully refreshed",
    },
    401: {
      description: "Unauthorized / Invalid Token",
    },
  },
});

// REGISTER PRAYER LOG ROUTES
registry.registerPath({
  method: "get",
  path: "/api/prayer-logs",
  summary: "Get all prayer logs",
  tags: ["Prayer Logs"],
  security: [{ [bearerAuth.name]: [] }],
  responses: {
    200: {
      description: "Success",
    },
    401: {
      description: "Unauthorized",
    },
  },
});

registry.registerPath({
  method: "post",
  path: "/api/prayer-logs",
  summary: "Create a new prayer log",
  tags: ["Prayer Logs"],
  security: [{ [bearerAuth.name]: [] }],
  request: {
    body: {
      content: {
        "application/json": {
          schema: logPrayerSchema,
        },
      },
    },
  },
  responses: {
    201: {
      description: "Created successfully",
    },
    401: {
      description: "Unauthorized",
    },
    422: {
      description: "Validation error",
    },
  },
});

registry.registerPath({
  method: "get",
  path: "/api/prayer-logs/summary",
  summary: "Get prayer log summary",
  tags: ["Prayer Logs"],
  security: [{ [bearerAuth.name]: [] }],
  request: {
    query: z.object({
      type: z
        .enum(["daily", "weekly", "monthly", "yearly", "all", "custom"])
        .optional()
        .default("all")
        .openapi({ description: "Type of summary" }),
      start_date: z.string().optional().openapi({
        description: "Start date (YYYY-MM-DD). Required if type is custom",
        example: "2024-03-01",
      }),
      end_date: z.string().optional().openapi({
        description: "End date (YYYY-MM-DD). Required if type is custom",
        example: "2024-03-31",
      }),
    }),
  },
  responses: {
    200: {
      description: "Success",
    },
    401: {
      description: "Unauthorized",
    },
    422: {
      description: "Validation error",
    },
  },
});

export const getOpenApiDocumentation = (): any => {
  const generator = new OpenApiGeneratorV3(registry.definitions);
  return generator.generateDocument({
    openapi: "3.0.0",
    info: {
      title: "HandlerClaw API",
      description: "API Documentation for HandlerClaw Project",
      version: "1.0.0",
    },
    servers: [{ url: "/", description: "Root Server" }],
  });
};
