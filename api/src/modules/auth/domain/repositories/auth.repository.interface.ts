import type { User } from "../../../../lib/generated/prisma/client.js";
import type { UpdateUserData } from "../../application/dtos/auth.dto.js";

export interface AuthRepository {
  findByEmail(email: string): Promise<User | null>;
  findById(id: string): Promise<User | null>;
  update(id: string, data: UpdateUserData): Promise<User>;
}
