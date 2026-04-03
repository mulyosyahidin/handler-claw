declare global {
  namespace Express {
    interface Request {
      userId: string;
      email: string;
      rawBody?: Buffer;
    }
  }
}

export {};
