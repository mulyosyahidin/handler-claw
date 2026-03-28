export class AppError extends Error {
  public readonly statusCode: number;
  public readonly errors?: Record<string, any>;

  constructor(message: string, statusCode: number, errors?: Record<string, any>) {
    super(message);

    this.statusCode = statusCode;

    if (errors !== undefined) {
      this.errors = errors;
    }

    Error.captureStackTrace(this, this.constructor);
  }
}
