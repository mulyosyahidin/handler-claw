import type { PrayerLogRepository } from "../../domain/repositories/prayer-log.repository.interface.js";
import type { DeletePrayerLogParams, DeletePrayerLogResponse } from "../dtos/prayer-log.dto.js";

export class DeletePrayerLogUseCase {
  constructor(private prayerLogRepository: PrayerLogRepository) {}

  async execute(userId: string, params: DeletePrayerLogParams): Promise<DeletePrayerLogResponse> {
    const existing = await this.prayerLogRepository.findById(params.id);

    if (!existing || existing.user_id !== userId) {
      throw new Error("Prayer log not found");
    }

    await this.prayerLogRepository.delete(params.id);

    return { success: true };
  }
}
