import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import type { UserRepository } from "../../../../auth/domain/repositories/user.repository.interface.js";
import { toWhatsappLogEntity } from "../../infrastructure/mappers/whatsapp-log.mapper.js";
import type {
  CreateWhatsappLogData,
  CreateWhatsappLogRequest,
  CreateWhatsappLogResponse,
} from "../dtos/whatsapp-log.dto.js";

export class CreateWhatsappLogUseCase {
  constructor(
    private whatsappLogRepository: WhatsappLogRepository,
    private userRepository: UserRepository,
  ) {}

  async execute(
    userId: string | null,
    input: CreateWhatsappLogRequest,
  ): Promise<CreateWhatsappLogResponse> {
    let validatedUserId: string | null = null;

    if (userId) {
      const user = await this.userRepository.findById(userId);
      if (user) {
        validatedUserId = userId;
      }
    }

    const data = input;
    const mappedData: CreateWhatsappLogData = {
      userId: validatedUserId,
      device: data.device,
      mode: data.mode,
      sender: data.sender || data.pengirim || "",
      senderLid: data.senderlid ?? null,
      senderName: data.name ?? null,
      isGroup: data.isgroup,
      groupId: data.isgroup ? data.sender : null,
      memberPhone: data.member ?? null,
      memberLid: data.memberlid ?? null,
      messageText: data.pesan || data.message || "",
      messageType: data.type,
      isForwarded: data.isforwarded,
      isQuick: data.quick,
      inboxId: data.inboxid,
      extension: data.extension ?? null,
      filename: data.filename ?? null,
      url: data.url ?? null,
      location: data.location ?? null,
      pollName: data.pollname ?? null,
      pollChoices: data.choices ?? [],
      waTimestamp: data.timestamp,
    };

    const log = await this.whatsappLogRepository.create(mappedData);

    return {
      whatsapp_log: toWhatsappLogEntity(log),
    };
  }
}
