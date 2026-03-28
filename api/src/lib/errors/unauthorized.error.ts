import { AppError } from "./app.error.js";

export class UnauthorizedError extends AppError {
  constructor(message = "Unauthorized", errors?: Record<string, any>) {
    super(message, 401, errors);
    this.name = "UnauthorizedError";
  }
}
