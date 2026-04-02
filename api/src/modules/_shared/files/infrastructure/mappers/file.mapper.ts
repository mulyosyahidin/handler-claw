import { type File as PrismaFile } from "../../../../../lib/generated/prisma/client.js";
import type { IFile } from "../../domain/entities/file.entity.js";

export function toFileEntity(data: PrismaFile): IFile {
  return {
    id: data.id,
    file_name: data.fileName,
    file_type: data.fileType,
    file_size: data.fileSize,
    file_path: data.filePath,
    created_at: data.createdAt,
    updated_at: data.updatedAt,
  };
}
