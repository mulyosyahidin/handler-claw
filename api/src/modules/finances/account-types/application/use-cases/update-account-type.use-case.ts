import type { AccountTypeRepository } from "../../domain/repositories/account-type.repository.interface.js";
import { toAccountTypeEntity } from "../../infrastructure/mappers/account-type.mapper.js";
import type {
  UpdateAccountTypeRequest,
  UpdateAccountTypeResponse,
} from "../dtos/account-type.dto.js";

export class UpdateAccountTypeUseCase {
  constructor(private accountTypeRepository: AccountTypeRepository) {}

  async execute(
    _userId: string,
    id: string,
    input: UpdateAccountTypeRequest,
  ): Promise<UpdateAccountTypeResponse> {
    // Clean undefined values for exactOptionalPropertyTypes
    const updateData: any = {};
    if (input.name !== undefined) updateData.name = input.name;
    if (input.category !== undefined) updateData.category = input.category;

    const updatedAccountType = await this.accountTypeRepository.update(id, updateData);

    return {
      account_type: toAccountTypeEntity(updatedAccountType),
    };
  }
}
