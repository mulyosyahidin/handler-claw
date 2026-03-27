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
      $queryRaw: vi.fn(),
    },
  };
});

describe("System Integration Tests", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("GET /", () => {
    it("should return welcome message", async () => {
      const res = await request(app).get("/api");
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.message).toContain("Welcome");
    });
  });

  describe("GET /health-check", () => {
    it("should return 200 and health status", async () => {
      vi.mocked(prisma.$queryRaw).mockResolvedValue([{ 1: 1 }] as any);

      const res = await request(app).get("/api/health-check");

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.database).toBe("connected");
    });
  });
});
