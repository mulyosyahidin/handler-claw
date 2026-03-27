import express, { type Express } from "express";
import basicAuth from "express-basic-auth";
import { requestLogger } from "./middleware/index.js";
import router from "./routes/router.js";
import { apiReference } from "@scalar/express-api-reference";
import { getOpenApiDocumentation } from "./lib/openapi-registry.js";

const app: Express = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

app.use("/api", router);

app.use(
  "/docs",
  basicAuth({
    users: { [process.env.DOCS_USERNAME || "admin"]: process.env.DOCS_PASSWORD || "admin" },
    challenge: true,
    realm: "HandlerClaw API Docs",
  }),
  apiReference({
    theme: "purple",
    content: getOpenApiDocumentation(),
  }),
);

export default app;
