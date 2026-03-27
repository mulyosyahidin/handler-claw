import { describe, it, expect, vi, beforeEach } from "vitest";
import request from "supertest";
import app from "../../../app.js";
import { prisma } from "../../../config/index.js";
import bcrypt from "bcrypt";
import * as jose from "../../../lib/jose.js";

// Mock Prisma
vi.mock("../../../config/index.js", async (importOriginal) => {
  const actual = await importOriginal<any>();
  return {
    ...actual,
    prisma: {
      user: {
        findUnique: vi.fn(),
        update: vi.fn(),
      },
    },
  };
});

// Mock jose.js
vi.mock("../../../lib/jose.js", () => ({
  createAccessToken: vi.fn(),
  refreshAccessToken: vi.fn(),
  verifyAccessToken: vi.fn(),
}));

// Mock bcrypt
vi.mock("bcrypt", () => ({
  default: {
    compare: vi.fn(),
    hash: vi.fn(),
  },
}));

describe("Auth Integration Tests", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe("POST /api/auth/login", () => {
    it("should return 200 and tokens on successful login", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        password: "hashedPassword",
        name: "Test User",
        lastLoginAt: null,
      };

      vi.mocked(prisma.user.findUnique).mockResolvedValue(mockUser as any);
      vi.mocked(bcrypt.compare).mockResolvedValue(true as never);
      vi.mocked(jose.createAccessToken).mockResolvedValue("mock-access-token");

      const res = await request(app)
        .post("/api/auth/login")
        .send({ email: "test@example.com", password: "password123" });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.access_token).toBe("mock-access-token");
      expect(res.body.data.user.email).toBe("test@example.com");
    });

    it("should return 401 on incorrect credentials", async () => {
      vi.mocked(prisma.user.findUnique).mockResolvedValue(null);

      const res = await request(app)
        .post("/api/auth/login")
        .send({ email: "wrong@example.com", password: "password123" });

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });

  describe("GET /api/auth/profile", () => {
    it("should return 200 and user profile when token is valid", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        name: "Test User",
        lastLoginAt: null,
      };

      vi.mocked(jose.verifyAccessToken).mockResolvedValue({
        userId: "user-1",
        email: "test@example.com",
      } as any);
      vi.mocked(prisma.user.findUnique).mockResolvedValue(mockUser as any);

      const res = await request(app)
        .get("/api/auth/profile")
        .set("Authorization", "Bearer valid-token");

      expect(res.status).toBe(200);
      expect(res.body.data.user.email).toBe("test@example.com");
    });

    it("should return 401 when token is missing", async () => {
      const res = await request(app).get("/api/auth/profile");

      expect(res.status).toBe(401);
      expect(res.body.success).toBe(false);
    });
  });
});
