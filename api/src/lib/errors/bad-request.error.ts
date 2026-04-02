import { AppError } from "./app.error.js";

export class BadRequestError extends AppError {
  constructor(message = "Bad Request", errors?: Record<string, any>) {
    super(message, 400, errors);
    this.name = "BadRequestError";
  }
}
