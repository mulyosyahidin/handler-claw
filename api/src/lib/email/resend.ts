import { Resend } from "resend";
import { renderTemplate } from "./templating.js";
import { prisma } from "../../config/index.js";

const RESEND_API_KEY = process.env.RESEND_API_KEY;

if (!RESEND_API_KEY) {
  // We log it but only throw if we attempt to use it, to avoid crashing on start if not configured
  console.warn("WARNING: RESEND_API_KEY is not defined in the environment variables.");
}

export const resend = new Resend(RESEND_API_KEY);

export interface SendEmailPayload {
  to: string | string[];
  subject: string;
  html: string;
  text?: string;
  from?: string;
  attachments?: any[];
  /** @internal */
  _logType?: "PLAIN" | "TEMPLATE";
  /** @internal */
  _templateName?: string;
  /** @internal */
  _context?: Record<string, any>;
}

export interface SendTemplatePayload {
  to: string | string[];
  subject: string;
  template: string;
  context: Record<string, any>;
  from?: string;
  attachments?: any[];
}

/**
 * Reusable helper function to send emails via Resend.
 * Easily supports single or multiple recipients, HTML/Text content, and attachments.
 *
 * @example
 * await sendEmail({
 *   to: "user@example.com",
 *   subject: "Hello World",
 *   html: "<strong>Congrats!</strong>",
 * });
 */
export async function sendEmail(payload: SendEmailPayload) {
  if (!RESEND_API_KEY) {
    throw new Error("Cannot send email: RESEND_API_KEY is missing.");
  }

  const from = payload.from || process.env.RESEND_FROM_EMAIL || "no-reply@martinss.me";
  const toStr = Array.isArray(payload.to) ? payload.to.join(", ") : payload.to;
  const attachmentMeta = payload.attachments?.map((a) => a.filename || "unnamed") || [];

  try {
    const { data, error } = await resend.emails.send({
      from,
      to: payload.to,
      subject: payload.subject,
      html: payload.html,
      ...(payload.text ? { text: payload.text } : {}),
      ...(payload.attachments ? { attachments: payload.attachments } : {}),
    });

    if (error) {
      await prisma.emailLog.create({
        data: {
          from,
          to: toStr,
          subject: payload.subject,
          type: payload._logType || "PLAIN",
          attachments: attachmentMeta,
          status: "FAILED",
          errorMessage: error.message,
          ...(payload._templateName ? { templateName: payload._templateName } : {}),
          ...(payload._context ? { context: payload._context } : {}),
        },
      });
      console.error("Resend API Error:", error);
      throw error;
    }

    await prisma.emailLog.create({
      data: {
        from,
        to: toStr,
        subject: payload.subject,
        type: payload._logType || "PLAIN",
        attachments: attachmentMeta,
        status: "SENT",
        ...(payload._templateName ? { templateName: payload._templateName } : {}),
        ...(payload._context ? { context: payload._context } : {}),
        ...(data?.id ? { resendId: data.id } : {}),
      },
    });

    return data;
  } catch (err: any) {
    // Catch-all for network or unexpected errors
    await prisma.emailLog.create({
      data: {
        from,
        to: toStr,
        subject: payload.subject,
        type: payload._logType || "PLAIN",
        attachments: attachmentMeta,
        status: "FAILED",
        errorMessage: err.message || "Unknown error occurred during email sending",
        ...(payload._templateName ? { templateName: payload._templateName } : {}),
        ...(payload._context ? { context: payload._context } : {}),
      },
    });
    console.error("Resend delivery failure:", err);
    throw err;
  }
}

/**
 * Sends an email using a Handlebars template.
 * The template should exist in `src/templates/emails/` as a `.hbs` file.
 *
 * @example
 * await sendEmailWithTemplate({
 *   to: "user@example.com",
 *   subject: "Selamat Datang!",
 *   template: "welcome",
 *   context: { name: "Budiman", appUrl: "https://handlerclaw.com" },
 * });
 */
export async function sendEmailWithTemplate(payload: SendTemplatePayload) {
  const html = await renderTemplate(payload.template, payload.context, payload.subject);

  return sendEmail({
    to: payload.to,
    subject: payload.subject,
    html,
    _logType: "TEMPLATE",
    _templateName: payload.template,
    _context: payload.context,
    ...(payload.from ? { from: payload.from } : {}),
    ...(payload.attachments ? { attachments: payload.attachments } : {}),
  });
}

export default resend;
