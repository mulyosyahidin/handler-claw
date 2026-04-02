import { AppError } from "./app.error.js";

export class NotFoundError extends AppError {
  constructor(message = "Resource not found", errors?: Record<string, any>) {
    super(message, 404, errors);
  }
}
