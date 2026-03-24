import { OpenAPIRegistry, OpenApiGeneratorV3 } from "@asteasolutions/zod-to-openapi";
import { loginSchema, logPrayerSchema } from "./schemas/index.js";

export const registry = new OpenAPIRegistry();

// REGISTER AUTH ROUTES
registry.registerPath({
  method: "post",
  path: "/api/auth/login",
  summary: "User Login",
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
  },
});

// REGISTER PRAYER LOG ROUTES
registry.registerPath({
  method: "get",
  path: "/api/prayer-logs",
  summary: "Get all logs",
  responses: {
    200: {
      description: "Success",
    },
  },
});

registry.registerPath({
  method: "post",
  path: "/api/prayer-logs",
  summary: "Create a new prayer log",
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
  },
});

export const getOpenApiDocumentation = (): any => {
  const generator = new OpenApiGeneratorV3(registry.definitions);
  return generator.generateDocument({
    openapi: "3.0.0",
    info: { title: "HandlerClaw API", version: "1.0.0" },
  });
};
