import express, { type Express } from "express";
import basicAuth from "express-basic-auth";
import { requestLogger } from "./middleware/index.js";
import router from "./routes/router.js";
import { apiReference } from "@scalar/express-api-reference";
import { getOpenApiDocumentation } from "./lib/openapi-registry.js";

const app: Express = express();

app.use(
  express.json({
    verify: (req: any, _res, buf) => {
      req.rawBody = buf;
    },
  }),
);
app.use(
  express.urlencoded({
    extended: true,
    verify: (req: any, _res, buf) => {
      req.rawBody = buf;
    },
  }),
);
app.use(express.static("public"));
app.use(requestLogger);

// Fix "Do not know how to serialize a BigInt" error for JSON responses
app.set("json replacer", (_key: string, value: any) =>
  typeof value === "bigint" ? value.toString() : value,
);

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
