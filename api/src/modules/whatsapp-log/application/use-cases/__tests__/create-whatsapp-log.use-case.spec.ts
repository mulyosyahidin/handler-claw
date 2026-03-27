import { describe, it, expect, vi, beforeEach } from "vitest";
import { CreateWhatsappLogUseCase } from "../create-whatsapp-log.use-case.js";
import type { WhatsappLogRepository } from "../../../domain/repositories/whatsapp-log.repository.interface.js";

describe("CreateWhatsappLogUseCase", () => {
  let createWhatsappLogUseCase: CreateWhatsappLogUseCase;
  let mockWhatsappLogRepository: WhatsappLogRepository;

  beforeEach(() => {
    mockWhatsappLogRepository = {
      create: vi.fn(),
      findMany: vi.fn(),
      getSummaryData: vi.fn(),
    };

    createWhatsappLogUseCase = new CreateWhatsappLogUseCase(mockWhatsappLogRepository);
  });

  it("should create whatsapp log successfully", async () => {
    const mockInput = {
      device: "device-1",
      mode: "mode-1",
      quick: false,
      inboxid: "inbox-1",
      sender: "123456",
      isgroup: false,
      type: "chat",
      isforwarded: false,
      timestamp: 123456789,
    };

    const mockResult = {
      id: 1,
      receivedAt: new Date(),
      waTimestamp: BigInt(123456789),
      ...mockInput,
      isQuick: false,
      inboxId: "inbox-1",
      senderLid: null,
      senderName: null,
      groupId: null,
      memberPhone: null,
      memberLid: null,
      messageText: null,
      messageType: "chat",
      isForwarded: false,
      extension: null,
      filename: null,
      url: null,
      location: null,
      pollName: null,
      pollChoices: null,
    };

    vi.mocked(mockWhatsappLogRepository.create).mockResolvedValue(mockResult as any);

    const result = await createWhatsappLogUseCase.execute(mockInput as any);

    expect(result.whatsapp_log.id).toBe(1);
    expect(mockWhatsappLogRepository.create).toHaveBeenCalled();
  });
});
