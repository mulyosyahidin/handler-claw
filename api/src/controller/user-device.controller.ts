import type { Response } from "express";
import type { AuthRequest } from "../middleware/auth.middleware.js";
import type { UserDeviceService } from "../service/index.js";
import {
  createUserDeviceSchema,
  updateUserDeviceStatusSchema,
  getUserDevicesQuerySchema,
} from "../lib/schemas/user-device.schema.js";
import { zodErrorMapper } from "../utils/zod.js";
import { createErrorResponse } from "../lib/types/response.js";

export class UserDeviceController {
  private userDeviceService: UserDeviceService;

  constructor(userDeviceService: UserDeviceService) {
    this.userDeviceService = userDeviceService;
  }

  // POST /api/user-devices
  createDevice = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = createUserDeviceSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const result = await this.userDeviceService.createDevice(userId, parsed.data);
    res.status(201).json(result);
  };

  // GET /api/user-devices
  getDevices = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = getUserDevicesQuerySchema.safeParse(req.query);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const result = await this.userDeviceService.getDevices(userId, parsed.data);
    res.status(200).json(result);
  };

  // GET /api/user-devices/:id
  getDeviceById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    const id = req.params.id as string;

    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    try {
      const result = await this.userDeviceService.getDeviceById(userId, id);
      res.status(200).json(result);
    } catch (error) {
      res.status(404).json(createErrorResponse("Device tidak ditemukan", { id: "ID tidak valid atau bukan milik Anda" }));
    }
  };

  // PATCH /api/user-devices/status
  updateDeviceStatus = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsed = updateUserDeviceStatusSchema.safeParse(req.body);

    if (!parsed.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsed.error),
        }),
      );
      return;
    }

    const result = await this.userDeviceService.updateDeviceStatus(userId, parsed.data);
    res.status(200).json(result);
  };
}
