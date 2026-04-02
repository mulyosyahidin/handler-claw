import type { User } from "../../../../lib/generated/prisma/client.js";
import type {
  CreateUserData,
  UpdateUserData,
  UserFilter,
} from "../../application/dtos/auth.dto.js";

export interface UserRepository {
  findByEmail(email: string): Promise<User | null>;

  findById(id: string): Promise<User | null>;

  findFirst(where: UserFilter): Promise<User | null>;

  update(id: string, data: UpdateUserData): Promise<User>;

  create(data: CreateUserData): Promise<User>;
}
