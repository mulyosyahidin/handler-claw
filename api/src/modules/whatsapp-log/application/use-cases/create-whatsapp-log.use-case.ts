import { type Prisma } from "../../../../lib/generated/prisma/client.js";
import type { WhatsappLogRepository } from "../../domain/repositories/whatsapp-log.repository.interface.js";
import type { CreateWhatsappLogInput } from "../../infrastructure/models/whatsapp-log.schema.js";
import type { CreateWhatsappLogResponse } from "../dtos/whatsapp-log.dto.js";

export class CreateWhatsappLogUseCase {
  constructor(private whatsappLogRepository: WhatsappLogRepository) {}

  async execute(input: CreateWhatsappLogInput): Promise<CreateWhatsappLogResponse> {
    const data: Prisma.WhatsappLogCreateInput = {
      receivedAt: new Date(),
      device: input.device,
      mode: input.mode,
      sender: input.sender,
      senderLid: input.senderlid ?? null,
      senderName: input.name ?? null,
      isGroup: input.isgroup,
      groupId: "",
      memberPhone: input.member || "",
      memberLid: input.memberlid || "",
      messageText: input.message || input.text || "",
      messageType: input.type,
      isForwarded: input.isforwarded,
      isQuick: input.quick,
      inboxId: input.inboxid,
      extension: input.extension ?? "",
      filename: input.filename ?? "",
      url: input.url ?? "",
      location: input.location ?? "",
      pollName: input.pollname ?? "",
      pollChoices: input.choices,
      waTimestamp: BigInt(input.timestamp),
    };

    const log = await this.whatsappLogRepository.create(data);

    return {
      whatsapp_log: log,
    };
  }
}
