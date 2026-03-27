import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../../../app.js";
import { prisma } from "../../../config/index.js";
import { createAccessToken } from "../../../lib/jose.js";
import { UserDevicePlatform, UserDeviceStatus } from "../../../lib/generated/prisma/client.js";

// Mock Prisma
vi.mock("../../../config/index.js", async (importOriginal) => {
  const actual = await importOriginal<any>();
  return {
    ...actual,
    prisma: {
      userDevice: {
        upsert: vi.fn(),
        findMany: vi.fn(),
        findFirst: vi.fn(),
        update: vi.fn(),
        count: vi.fn(),
      },
      user: {
        findUnique: vi.fn(),
      },
    },
  };
});

describe("User Device Integration Tests", () => {
  let token: string;
  const userId = "user-123";
  const email = "test@example.com";

  beforeEach(async () => {
    vi.clearAllMocks();
    token = await createAccessToken({ userId, email });
  });

  describe("POST /api/user-devices", () => {
    it("should return 201 on successful device registration", async () => {
      const mockInput = {
        device_id: "dev-1",
        device_brand: "Samsung",
        fcm_token: "token-1",
        platform: UserDevicePlatform.ANDROID,
      };

      vi.mocked(prisma.userDevice.upsert).mockResolvedValue({
        id: "uuid-1",
        userId,
        deviceId: "dev-1",
        deviceBrand: "Samsung",
        fcmToken: "token-1",
        platform: UserDevicePlatform.ANDROID,
        status: UserDeviceStatus.ACTIVE,
        lastSeenAt: new Date(),
        createdAt: new Date(),
        updatedAt: new Date(),
      } as any);

      const res = await request(app)
        .post("/api/user-devices")
        .set("Authorization", `Bearer ${token}`)
        .send(mockInput);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user_device.id).toBe("uuid-1");
    });
  });

  describe("GET /api/user-devices", () => {
    it("should return 200 and list of devices", async () => {
      vi.mocked(prisma.userDevice.findMany).mockResolvedValue([]);
      vi.mocked(prisma.userDevice.count).mockResolvedValue(0);

      const res = await request(app)
        .get("/api/user-devices")
        .set("Authorization", `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user_devices).toBeInstanceOf(Array);
    });
  });

  describe("PATCH /api/user-devices/status", () => {
    it("should return 200 on successful status update", async () => {
      const mockInput = {
        fcm_token: "token-1",
        status: UserDeviceStatus.LOGGED_OUT,
      };

      vi.mocked(prisma.userDevice.update).mockResolvedValue({
        id: "uuid-1",
        status: UserDeviceStatus.LOGGED_OUT,
      } as any);

      const res = await request(app)
        .patch("/api/user-devices/status")
        .set("Authorization", `Bearer ${token}`)
        .send(mockInput);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user_device.status).toBe(UserDeviceStatus.LOGGED_OUT);
    });
  });

  describe("GET /api/user-devices/:id", () => {
    it("should return 200 and device detail", async () => {
      const deviceId = "550e8400-e29b-41d4-a716-446655440000";
      vi.mocked(prisma.userDevice.findFirst).mockResolvedValue({
        id: deviceId,
        userId,
      } as any);

      const res = await request(app)
        .get(`/api/user-devices/${deviceId}`)
        .set("Authorization", `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.user_device.id).toBe(deviceId);
    });

    it("should return 404 if device not found", async () => {
      const deviceId = "550e8400-e29b-41d4-a716-446655440000";
      vi.mocked(prisma.userDevice.findFirst).mockResolvedValue(null);

      const res = await request(app)
        .get(`/api/user-devices/${deviceId}`)
        .set("Authorization", `Bearer ${token}`);

      expect(res.status).toBe(404);
    });
  });
});
