import { AppError } from "./app.error.js";

export class ConflictError extends AppError {
  constructor(message = "Conflict", errors?: Record<string, any>) {
    super(message, 409, errors);
    this.name = "ConflictError";
  }
}
