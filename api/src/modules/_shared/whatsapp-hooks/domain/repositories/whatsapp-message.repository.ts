import type { WhatsappMessage } from "../../../../../lib/generated/prisma/client.js";
import type { CreateWhatsappMessageData } from "../../application/dtos/whatsapp-message.dto.js";

export interface WhatsappMessageRepository {
  create(data: CreateWhatsappMessageData): Promise<WhatsappMessage>;
  findById(id: string): Promise<WhatsappMessage | null>;
  findAll(
    filter: any,
    options: { skip: number; take: number },
  ): Promise<{ messages: WhatsappMessage[]; total: number }>;
}
