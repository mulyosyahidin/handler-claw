import { OpenAPIRegistry, OpenApiGeneratorV3 } from "@asteasolutions/zod-to-openapi";
import {
  loginSchema,
  refreshTokenSchema,
} from "../modules/auth/infrastructure/models/auth.schema.js";
import { logPrayerSchema } from "../modules/prayer-log/infrastructure/models/prayer-log.schema.js";
import { z } from "zod";

const prayerDateTypeEnum = z.enum([
  "today",
  "this_week",
  "this_month",
  "this_year",
  "7_days",
  "30_days",
  "1_year",
  "all",
  "custom",
]);

const dateRangeOpenApi = {
  date_type: prayerDateTypeEnum
    .default("all")
    .openapi({ param: { name: "date_type", in: "query" }, description: "Period filter type" }),
  start: z
    .string()
    .optional()
    .openapi({ param: { name: "start", in: "query" }, description: "Start date (YYYY-MM-DD)" }),
  end: z
    .string()
    .optional()
    .openapi({ param: { name: "end", in: "query" }, description: "End date (YYYY-MM-DD)" }),
};

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
  request: {
    query: z.object({
      page: z
        .number()
        .default(1)
        .openapi({ param: { name: "page", in: "query" }, description: "Page number" }),
      per_page: z
        .number()
        .default(10)
        .openapi({ param: { name: "per_page", in: "query" }, description: "Items per page" }),
      ...dateRangeOpenApi,
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
    query: z.object(dateRangeOpenApi),
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

// REGISTER OVERVIEW ROUTES
registry.registerPath({
  method: "get",
  path: "/api/overview",
  summary: "Get system overview/summary",
  tags: ["Overview"],
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
