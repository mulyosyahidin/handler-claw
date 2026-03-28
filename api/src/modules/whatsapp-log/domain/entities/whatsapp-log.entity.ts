export type IWhatsappLog = {
  id: string;
  received_at: Date;

  // Device & routing
  device: string;
  mode: string;

  // Sender info
  sender: string;
  sender_lid: string | null;
  sender_name: string | null;

  // Group info
  is_group: boolean;
  group_id: string | null;
  member_phone: string | null;
  member_lid: string | null;

  // Message
  message_text: string | null;
  message_type: string;
  is_forwarded: boolean;
  is_quick: boolean;
  inbox_id: number;

  // Media
  extension: string | null;
  filename: string | null;
  url: string | null;
  location: string | null;

  // Poll
  poll_name: string | null;
  poll_choices: unknown | null;

  wa_timestamp: string;
};
