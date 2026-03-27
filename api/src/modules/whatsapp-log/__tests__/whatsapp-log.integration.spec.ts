import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../../../app.js";
import { prisma } from "../../../config/index.js";

// Mock Prisma
vi.mock("../../../config/index.js", async (importOriginal) => {
  const actual = await importOriginal<any>();
  return {
    ...actual,
    prisma: {
      whatsappLog: {
        create: vi.fn(),
        findMany: vi.fn(),
        count: vi.fn(),
        groupBy: vi.fn(),
      },
    },
  };
});

describe("WhatsApp Log Integration Tests", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("POST /api/whatsapp-logs", () => {
    it("should return 201 on successful log creation", async () => {
      const mockLog = {
        device: "d1",
        mode: "m1",
        quick: false,
        inboxid: 1,
        sender: "123",
        isgroup: false,
        type: "chat",
        isforwarded: false,
        timestamp: 123456,
      };

      vi.mocked(prisma.whatsappLog.create).mockResolvedValue({
        id: 1,
        receivedAt: new Date(),
        waTimestamp: BigInt(123456),
        device: "d1",
        mode: "m1",
        isQuick: false,
        inboxId: "i1",
        sender: "123",
        isGroup: false,
        messageType: "chat",
        isForwarded: false,
      } as any);

      const res = await request(app).post("/api/whatsapp-logs").send(mockLog);

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.whatsapp_log.id).toBe(1);
    });

    it("should return 422 on invalid input", async () => {
      const res = await request(app).post("/api/whatsapp-logs").send({});
      expect(res.status).toBe(422);
    });
  });

  describe("GET /api/whatsapp-logs", () => {
    it("should return 200 and list of logs", async () => {
      vi.mocked(prisma.whatsappLog.findMany).mockResolvedValue([]);

      const res = await request(app).get("/api/whatsapp-logs").query({ date_type: "today" });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.whatsapp_logs).toBeInstanceOf(Array);
    });
  });

  describe("GET /api/whatsapp-logs/summary", () => {
    it("should return 200 and summary data", async () => {
      vi.mocked(prisma.whatsappLog.count).mockResolvedValue(0);
      vi.mocked(prisma.whatsappLog.groupBy).mockResolvedValue([]);
      vi.mocked(prisma.whatsappLog.findMany).mockResolvedValue([]);

      const res = await request(app)
        .get("/api/whatsapp-logs/summary")
        .query({ date_type: "today" });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.total).toBe(0);
    });
  });
});
