import type { FileRepository } from "../../domain/repositories/file.repository.interface.js";
import { toFileEntity } from "../../infrastructure/mappers/file.mapper.js";
import type { UploadFileRequest, UploadFileResponse } from "../dtos/file.dto.js";

export class UploadFileUseCase {
  constructor(private fileRepository: FileRepository) {}

  async execute(data: UploadFileRequest): Promise<UploadFileResponse> {
    const file = await this.fileRepository.create({
      fileName: data.fileName,
      fileType: data.fileType,
      fileSize: data.fileSize,
      filePath: data.filePath,
    });

    return { file: toFileEntity(file) };
  }
}
