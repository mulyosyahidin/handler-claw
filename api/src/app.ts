import express, { type Express } from "express";
import { requestLogger } from "./middleware/index.js";
import router from "./route/router.js";

const app: Express = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(requestLogger);

app.use("/api", router);

export default app;
