import bcrypt from "bcrypt";
import type { PasswordService } from "../../domain/services/password.service.interface.js";

export class BcryptPasswordService implements PasswordService {
  async compare(plain: string, hashed: string): Promise<boolean> {
    return bcrypt.compare(plain, hashed);
  }

  async hash(plain: string): Promise<string> {
    return bcrypt.hash(plain, 10);
  }
}
