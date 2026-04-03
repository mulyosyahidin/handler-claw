import { WhatsappMessageType } from "../../../../../lib/generated/prisma/client.js";
import type { WhatsappMessageRepository } from "../../domain/repositories/whatsapp-message.repository.js";
import type { CreateWhatsappMessageData } from "../dtos/whatsapp-message.dto.js";
import logger from "../../../../../config/logger.js";
import { downloadRemoteMedia } from "../../../../../utils/file-storage.js";
import type { IWhatsappMessage } from "../../domain/entities/whatsapp-message.entity.js";
import { toWhatsappMessageEntity } from "../../infrastructure/mappers/whatsapp-message.mapper.js";

export class CreateWhatsappMessageUseCase {
  constructor(private whatsappMessageRepository: WhatsappMessageRepository) {}

  async execute(webhookLogId: string, payload: any): Promise<IWhatsappMessage | null> {
    try {
      const data = await this.mapPayloadToData(webhookLogId, payload);
      const created = await this.whatsappMessageRepository.create(data);
      return toWhatsappMessageEntity(created);
    } catch (error) {
      logger.error("CreateWhatsappMessageUseCase::execute() mapping/download error", error);
      return null;
    }
  }

  private async mapPayloadToData(
    webhookLogId: string,
    payload: any,
  ): Promise<CreateWhatsappMessageData> {
    const base: CreateWhatsappMessageData = {
      id: payload.id,
      webhookLogId,
      chatId: payload.chat_id,
      chatLid: payload.chat_lid,
      from: payload.from,
      fromLid: payload.from_lid,
      fromName: payload.from_name,
      isFromMe: payload.is_from_me || false,
      waTimestamp: payload.timestamp,
      messageType: WhatsappMessageType.TEXT, // Default
      body: payload.body,
      repliedToId: payload.replied_to_id,
      quotedBody: payload.quoted_body,
      isForwarded: payload.forwarded || false,
    };

    // Determine type and extract specific fields
    if (payload.image) {
      base.messageType = WhatsappMessageType.IMAGE;
      const remotePath = typeof payload.image === "string" ? payload.image : payload.image.path;
      base.mediaCaption = typeof payload.image === "object" ? payload.image.caption : payload.body;
      base.originalUrl = remotePath;

      const fullUrl = this.resolveRemoteUrl(remotePath);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, remotePath);
        } catch (err) {
          logger.warn(`Gagal mengunduh gambar WA: ${remotePath}`, err);
          base.mediaPath = remotePath; // Fallback
        }
      }
    } else if (payload.video) {
      base.messageType = WhatsappMessageType.VIDEO;
      const remotePath = typeof payload.video === "string" ? payload.video : payload.video.path;
      base.mediaCaption = typeof payload.video === "object" ? payload.video.caption : payload.body;
      base.originalUrl = remotePath;

      const fullUrl = this.resolveRemoteUrl(remotePath);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, remotePath);
        } catch (err) {
          logger.warn(`Gagal mengunduh video WA: ${remotePath}`, err);
          base.mediaPath = remotePath; // Fallback
        }
      }
    } else if (payload.audio) {
      base.messageType = WhatsappMessageType.AUDIO;
      base.originalUrl = payload.audio;
      const fullUrl = this.resolveRemoteUrl(payload.audio);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, payload.audio);
        } catch (err) {
          logger.warn(`Gagal mengunduh audio WA: ${payload.audio}`, err);
          base.mediaPath = payload.audio; // Fallback
        }
      }
    } else if (payload.document) {
      base.messageType = WhatsappMessageType.DOCUMENT;
      const remotePath =
        typeof payload.document === "string" ? payload.document : payload.document.path;
      base.mediaCaption =
        typeof payload.document === "object" ? payload.document.caption : payload.body;
      base.originalUrl = remotePath;

      const fullUrl = this.resolveRemoteUrl(remotePath);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, remotePath);
        } catch (err) {
          logger.warn(`Gagal mengunduh dokumen WA: ${remotePath}`, err);
          base.mediaPath = remotePath; // Fallback
        }
      }
    } else if (payload.sticker) {
      base.messageType = WhatsappMessageType.STICKER;
      base.originalUrl = payload.sticker;
      const fullUrl = this.resolveRemoteUrl(payload.sticker);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, payload.sticker);
        } catch (err) {
          logger.warn(`Gagal mengunduh stiker WA: ${payload.sticker}`, err);
          base.mediaPath = payload.sticker; // Fallback
        }
      }
    } else if (payload.video_note) {
      base.messageType = WhatsappMessageType.VIDEO_NOTE;
      base.originalUrl = payload.video_note;
      const fullUrl = this.resolveRemoteUrl(payload.video_note);
      if (fullUrl) {
        try {
          base.mediaPath = await downloadRemoteMedia(fullUrl, payload.video_note);
        } catch (err) {
          logger.warn(`Gagal mengunduh video note WA: ${payload.video_note}`, err);
          base.mediaPath = payload.video_note; // Fallback
        }
      }
    } else if (payload.location) {
      base.messageType = WhatsappMessageType.LOCATION;
      base.latitude = payload.location.degreesLatitude;
      base.longitude = payload.location.degreesLongitude;
      base.locationThumbnail = payload.location.JPEGThumbnail;
    } else if (payload.live_location) {
      base.messageType = WhatsappMessageType.LIVE_LOCATION;
      base.latitude = payload.live_location.degreesLatitude;
      base.longitude = payload.live_location.degreesLongitude;
      base.locationThumbnail = payload.live_location.JPEGThumbnail;
      base.locationSequence = payload.live_location.sequenceNumber;
      base.mediaCaption = payload.live_location.caption;
    } else if (payload.contact) {
      base.messageType = WhatsappMessageType.CONTACT;
      base.contactName = payload.contact.displayName;
      base.contactVcard = payload.contact.vcard;
    } else if (payload.contacts_array) {
      base.messageType = WhatsappMessageType.CONTACTS_ARRAY;
      base.contacts = payload.contacts_array;
    } else if (payload.reaction) {
      base.messageType = WhatsappMessageType.REACTION;
      base.reaction = payload.reaction;
      base.reactedMessageId = payload.reacted_message_id;
    }

    return base;
  }

  private resolveRemoteUrl(remotePath: string): string | null {
    const baseUrl = process.env.WAG_BASE_URL;
    if (!baseUrl) return null;

    const localizedPath = remotePath.startsWith("/") ? remotePath.substring(1) : remotePath;
    return `${baseUrl.endsWith("/") ? baseUrl : baseUrl + "/"}${localizedPath}`;
  }
}
