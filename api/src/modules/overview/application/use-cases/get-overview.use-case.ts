import type { GetOverviewResponse } from "../dtos/overview.dto.js";
import type { OverviewRepository } from "../../domain/repositories/overview.repository.interface.js";

export class GetOverviewUseCase {
  constructor(private overviewRepository: OverviewRepository) {}

  async execute(userId: string): Promise<GetOverviewResponse> {
    const counts = await this.overviewRepository.getCounts(userId);

    return {
      count: counts,
    };
  }
}
