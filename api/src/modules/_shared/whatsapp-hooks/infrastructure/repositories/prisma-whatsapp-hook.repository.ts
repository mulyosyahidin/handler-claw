import prisma from "../../../../../config/prisma.js";
import type { Prisma, WebhookLog } from "../../../../../lib/generated/prisma/client.js";
import type { CreateWebhookLogData } from "../../application/dtos/whatsapp-hook.dto.js";
import type { WhatsappHookRepository } from "../../domain/repositories/whatsapp-hook.repository.js";

export class PrismaWhatsappLogRepository implements WhatsappHookRepository {
  create(userId: string, data: CreateWebhookLogData): Promise<WebhookLog> {
    return prisma.webhookLog.create({
      data: {
        userId: userId,
        deviceId: data.deviceId,
        payload: data.payload as Prisma.InputJsonValue,
        event: data.event,
      },
    });
  }
}
