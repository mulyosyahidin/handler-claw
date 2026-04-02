import { prisma } from "../../../../../config/index.js";
import { type File as PrismaFile } from "../../../../../lib/generated/prisma/client.js";
import type { FileRepository } from "../../domain/repositories/file.repository.interface.js";
import type { CreateFileData } from "../../application/dtos/file.dto.js";

export class PrismaFileRepository implements FileRepository {
  async create(data: CreateFileData): Promise<PrismaFile> {
    return prisma.file.create({
      data: {
        fileName: data.fileName,
        fileType: data.fileType,
        fileSize: data.fileSize,
        filePath: data.filePath,
      },
    });
  }

  async findById(id: string): Promise<PrismaFile | null> {
    return prisma.file.findUnique({
      where: { id },
    });
  }
}
