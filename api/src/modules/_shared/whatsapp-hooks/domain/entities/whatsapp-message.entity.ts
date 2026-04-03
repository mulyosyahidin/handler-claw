import type { WhatsappMessageType, Prisma } from "../../../../../lib/generated/prisma/client.js";

export type IWhatsappMessage = {
  id: string;
  webhook_log_id: string;

  // Header info
  chat_id: string;
  chat_lid?: string | null;
  from: string;
  from_lid?: string | null;
  from_name?: string | null;
  is_from_me: boolean;
  wa_timestamp: Date;

  // Content
  message_type: WhatsappMessageType;
  body?: string | null;

  // Reply & Forward
  replied_to_id?: string | null;
  quoted_body?: string | null;
  is_forwarded: boolean;

  // Media
  media_path?: string | null;
  full_media_path?: string | null;
  media_caption?: string | null;
  original_url?: string | null;

  // Location
  latitude?: number | null;
  longitude?: number | null;
  location_thumbnail?: string | null;
  location_sequence?: bigint | null;

  // Contact
  contact_name?: string | null;
  contact_vcard?: string | null;
  contacts?: Prisma.JsonValue | null;

  // Reaction
  reaction?: string | null;
  reacted_message_id?: string | null;

  created_at: Date;
  updated_at: Date;
};
