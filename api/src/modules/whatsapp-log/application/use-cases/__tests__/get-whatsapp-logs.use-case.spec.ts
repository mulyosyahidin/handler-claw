import { describe, it, expect, vi, beforeEach } from "vitest";
import { GetWhatsappLogsUseCase } from "../get-whatsapp-logs.use-case.js";
import type { WhatsappLogRepository } from "../../../domain/repositories/whatsapp-log.repository.interface.js";

describe("GetWhatsappLogsUseCase", () => {
  let getWhatsappLogsUseCase: GetWhatsappLogsUseCase;
  let mockWhatsappLogRepository: WhatsappLogRepository;

  beforeEach(() => {
    mockWhatsappLogRepository = {
      create: vi.fn(),
      findMany: vi.fn(),
      getSummaryData: vi.fn(),
    };

    getWhatsappLogsUseCase = new GetWhatsappLogsUseCase(mockWhatsappLogRepository);
  });

  it("should get whatsapp logs successfully", async () => {
    const mockQuery = {
      take: 10,
    };

    const mockResult = {
      logs: [
        {
          id: 1,
          received_at: new Date(),
          wa_timestamp: BigInt(123456),
          device: "d1",
          sender: "s1",
          is_group: false,
          message_type: "chat",
          is_quick: false,
          is_forwarded: false,
        },
      ],
      nextCursor: null,
    };

    vi.mocked(mockWhatsappLogRepository.findMany).mockResolvedValue(mockResult as any);

    const result = await getWhatsappLogsUseCase.execute(mockQuery as any);

    expect(result.whatsapp_logs).toHaveLength(1);
    expect(result.next_cursor).toBeNull();
    expect(mockWhatsappLogRepository.findMany).toHaveBeenCalled();
  });
});
