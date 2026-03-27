import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import type { PasswordService } from "../../domain/services/password.service.interface.js";
import type { TokenService } from "../../domain/services/token.service.interface.js";
import type { LoginRequest } from "../../infrastructure/models/auth.schema.js";
import type { LoginResponse } from "../dtos/auth.dto.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";

export class LoginUseCase {
  constructor(
    private userRepository: UserRepository,
    private passwordService: PasswordService,
    private tokenService: TokenService,
  ) {}

  async execute(credentials: LoginRequest): Promise<LoginResponse> {
    const { email, password } = credentials;

    const user = await this.userRepository.findByEmail(email);

    if (!user) {
      throw {
        message: "Periksa kembali kredensial Anda",
        errors: { email: "Email atau password salah" },
      };
    }

    const isPasswordValid = await this.passwordService.compare(password, user.password);

    if (!isPasswordValid) {
      throw {
        message: "Periksa kembali kredensial Anda",
        errors: { password: "Email atau password salah" },
      };
    }

    await this.userRepository.updateLastLogin(user.id);

    const token = await this.tokenService.createAccessToken({
      userId: user.id,
      email: user.email,
    });

    return {
      user: toUserEntity(user),
      access_token: token,
    };
  }
}
