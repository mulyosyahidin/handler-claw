import type { UserRepository } from "../../domain/repositories/user.repository.interface.js";
import type { PasswordService } from "../../domain/services/password.service.interface.js";
import type { TokenService } from "../../domain/services/token.service.interface.js";
import type { LoginRequest, LoginResponse } from "../dtos/auth.dto.js";
import { toUserEntity } from "../../infrastructure/mappers/user.mapper.js";
import { UnauthorizedError } from "../../../../lib/errors/unauthorized.error.js";

export class LoginUseCase {
  constructor(
    private userRepository: UserRepository,
    private passwordService: PasswordService,
    private tokenService: TokenService,
  ) {}

  async execute(credentials: LoginRequest): Promise<LoginResponse> {
    const { email, password } = credentials;

    const user = await this.userRepository.findByEmail(email);

    const isPasswordValid =
      user && user.password && (await this.passwordService.compare(password, user.password));

    if (!user || !isPasswordValid) {
      throw new UnauthorizedError("Periksa kembali kredensial Anda", {
        credentials: "Email atau password salah",
      });
    }

    await this.userRepository.update(user.id, {
      lastLoginAt: new Date(),
    });

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
