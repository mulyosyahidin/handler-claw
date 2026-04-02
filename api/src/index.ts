import "dotenv/config";
import app from "./app.js";
import { logger } from "./config/index.js";

const PORT = process.env.APP_PORT || 3000;

app.listen(PORT, () => {
  logger.info(`Server is running on port ${PORT}`);
});
