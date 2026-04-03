import type { Response } from "express";
import { createErrorResponse, createSuccessResponse } from "../../../lib/types/response.js";
import { zodErrorMapper } from "../../../utils/zod.js";
import logger from "../../../config/logger.js";
import type { GetWhatsappMessagesUseCase } from "../../_shared/whatsapp-hooks/application/use-cases/get-whatsapp-messages.use-case.ts";
import { getWhatsappMessagesQuerySchema } from "../../_shared/whatsapp-hooks/infrastructure/models/whatsapp-hook.schema.js";
import type { AuthRequest } from "../../../middleware/auth.middleware.js";

export class WhatsappMessageController {
  constructor(private getWhatsappMessagesUseCase: GetWhatsappMessagesUseCase) {}

  getMessages = async (req: AuthRequest, res: Response) => {
    const userId = req.userId; // Authenticated user ID from middleware

    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { user_id: "User ID is required" }));
      return;
    }

    const parsed = getWhatsappMessagesQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getWhatsappMessagesUseCase.execute(userId, parsed.data as any);
      res.status(200).json(createSuccessResponse("Berhasil mengambil data pesan", result));
    } catch (error: any) {
      logger.error("WhatsappMessageController::getMessages() Error", error);
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
