import prisma from "../../../../../config/prisma.js";
import { type WhatsappMessage, Prisma } from "../../../../../lib/generated/prisma/client.js";
import type { CreateWhatsappMessageData } from "../../application/dtos/whatsapp-message.dto.js";
import type { WhatsappMessageRepository } from "../../domain/repositories/whatsapp-message.repository.js";

export class PrismaWhatsappMessageRepository implements WhatsappMessageRepository {
  async create(data: CreateWhatsappMessageData): Promise<WhatsappMessage> {
    const messageData = {
      id: data.id,
      webhookLogId: data.webhookLogId,
      chatId: data.chatId,
      chatLid: data.chatLid ?? null,
      from: data.from,
      fromLid: data.fromLid ?? null,
      fromName: data.fromName ?? null,
      isFromMe: data.isFromMe,
      waTimestamp: new Date(data.waTimestamp),
      messageType: data.messageType,
      body: data.body ?? null,
      repliedToId: data.repliedToId ?? null,
      quotedBody: data.quotedBody ?? null,
      isForwarded: data.isForwarded,
      mediaPath: data.mediaPath ?? null,
      mediaCaption: data.mediaCaption ?? null,
      originalUrl: data.originalUrl ?? null,
      latitude: data.latitude ?? null,
      longitude: data.longitude ?? null,
      locationThumbnail: data.locationThumbnail ?? null,
      locationSequence: data.locationSequence ? BigInt(data.locationSequence) : null,
      contactName: data.contactName ?? null,
      contactVcard: data.contactVcard ?? null,
      contacts: data.contacts ?? Prisma.DbNull,
      reaction: data.reaction ?? null,
      reactedMessageId: data.reactedMessageId ?? null,
    };

    return prisma.whatsappMessage.upsert({
      where: { id: data.id },
      update: messageData,
      create: messageData,
    });
  }

  async findById(id: string): Promise<WhatsappMessage | null> {
    return prisma.whatsappMessage.findUnique({
      where: { id },
    });
  }

  async findAll(
    filter: any,
    options: { skip: number; take: number },
  ): Promise<{ messages: WhatsappMessage[]; total: number }> {
    const { skip, take } = options;
    const { search, chatId, messageType, userId } = filter;

    const where: any = {};

    if (userId) {
      where.webhookLog = { userId };
    }

    if (chatId) {
      where.chatId = chatId;
    }

    if (messageType) {
      where.messageType = messageType;
    }

    if (filter.isFromMe !== undefined) {
      where.isFromMe = filter.isFromMe;
    }

    if (search) {
      where.OR = [
        { body: { contains: search, mode: "insensitive" } },
        { mediaCaption: { contains: search, mode: "insensitive" } },
        { fromName: { contains: search, mode: "insensitive" } },
      ];
    }

    const [messages, total] = await Promise.all([
      prisma.whatsappMessage.findMany({
        where,
        skip,
        take,
        orderBy: { waTimestamp: "desc" },
      }),
      prisma.whatsappMessage.count({ where }),
    ]);

    return { messages, total };
  }
}
