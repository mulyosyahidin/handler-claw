import type { Response } from "express";
import type { AuthRequest } from "../../../../middleware/auth.middleware.js";
import {
  createUserDeviceSchema,
  getUserDeviceParamsSchema,
  getUserDevicesQuerySchema,
  updateUserDeviceStatusSchema,
} from "../../infrastructure/models/user-device.schema.js";
import { zodErrorMapper } from "../../../../utils/zod.js";
import { createErrorResponse, createSuccessResponse } from "../../../../lib/types/response.js";
import type { RegisterUserDeviceUseCase } from "../../application/use-cases/register-user-device.use-case.js";
import type { GetUserDevicesUseCase } from "../../application/use-cases/get-user-devices.use-case.js";
import type { GetUserDeviceDetailUseCase } from "../../application/use-cases/get-user-device-detail.use-case.js";
import type { UpdateUserDeviceStatusUseCase } from "../../application/use-cases/update-user-device-status.use-case.js";

export class UserDeviceController {
  constructor(
    private registerUserDeviceUseCase: RegisterUserDeviceUseCase,
    private getUserDevicesUseCase: GetUserDevicesUseCase,
    private getDeviceDetailUseCase: GetUserDeviceDetailUseCase,
    private updateDeviceStatusUseCase: UpdateUserDeviceStatusUseCase,
  ) {}

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

    try {
      const result = await this.registerUserDeviceUseCase.execute(userId, parsed.data);
      res.status(201).json(createSuccessResponse("Berhasil mendaftarkan perangkat", result));
    } catch (error: any) {
      res.status(500).json(createErrorResponse(error.message, null));
    }
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

    try {
      const result = await this.getUserDevicesUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil mengambil daftar perangkat", result));
    } catch (error: any) {
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };

  // GET /api/user-devices/:id
  getDeviceById = async (req: AuthRequest, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      res.status(401).json(createErrorResponse("Unauthorized", { token: "Token tidak valid" }));
      return;
    }

    const parsedParams = getUserDeviceParamsSchema.safeParse(req.params);
    if (!parsedParams.success) {
      res.status(422).json(
        createErrorResponse("Validation error", {
          errors: zodErrorMapper(parsedParams.error),
        }),
      );
      return;
    }

    try {
      const result = await this.getDeviceDetailUseCase.execute(userId, {
        id: parsedParams.data.id,
      });
      res.status(200).json(createSuccessResponse("Berhasil mengambil detail perangkat", result));
    } catch (error: any) {
      res.status(404).json(
        createErrorResponse("Device tidak ditemukan", {
          id: error.message,
        }),
      );
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

    try {
      const result = await this.updateDeviceStatusUseCase.execute(userId, parsed.data);
      res.status(200).json(createSuccessResponse("Berhasil memperbarui status perangkat", result));
    } catch (error: any) {
      res.status(500).json(createErrorResponse(error.message, null));
    }
  };
}
