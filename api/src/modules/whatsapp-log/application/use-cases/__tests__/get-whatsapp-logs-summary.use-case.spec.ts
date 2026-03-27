import { describe, it, expect, vi, beforeEach } from "vitest";
import { GetWhatsappLogsSummaryUseCase } from "../get-whatsapp-logs-summary.use-case.js";
import type { WhatsappLogRepository } from "../../../domain/repositories/whatsapp-log.repository.interface.js";

describe("GetWhatsappLogsSummaryUseCase", () => {
  let getWhatsappLogsSummaryUseCase: GetWhatsappLogsSummaryUseCase;
  let mockWhatsappLogRepository: WhatsappLogRepository;

  beforeEach(() => {
    mockWhatsappLogRepository = {
      create: vi.fn(),
      findMany: vi.fn(),
      getSummaryData: vi.fn(),
    };

    getWhatsappLogsSummaryUseCase = new GetWhatsappLogsSummaryUseCase(mockWhatsappLogRepository);
  });

  it("should get whatsapp logs summary successfully", async () => {
    const mockQuery = {
      date_type: "today",
    };

    const mockResult = {
      total: 10,
      byDeviceRaw: [{ device: "d1", _count: { id: 5 } }],
      byMessageTypeRaw: [{ messageType: "chat", _count: { id: 10 } }],
      byIsGroupRaw: [{ isGroup: false, _count: { id: 10 } }],
      logsRaw: [
        {
          id: 1,
          receivedAt: new Date(),
          waTimestamp: BigInt(123456),
          device: "d1",
          sender: "s1",
          senderName: "User 1",
          isGroup: false,
          messageType: "chat",
          isQuick: false,
          isForwarded: false,
        },
      ],
      filterInfo: {
        date_start: "2026-03-27",
        date_end: "2026-03-27",
      },
    };

    vi.mocked(mockWhatsappLogRepository.getSummaryData).mockResolvedValue(mockResult as any);

    const result = await getWhatsappLogsSummaryUseCase.execute(mockQuery as any);

    expect(result.total).toBe(10);
    expect(result.by_device["d1"]).toBe(5);
    expect(result.by_chat_type.personal).toBe(10);
    expect(Object.keys(result.messages)).toHaveLength(1);
    expect(mockWhatsappLogRepository.getSummaryData).toHaveBeenCalled();
  });
});
