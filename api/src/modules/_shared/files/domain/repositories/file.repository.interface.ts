import { type File as PrismaFile } from "../../../../../lib/generated/prisma/client.js";
import type { CreateFileData } from "../../application/dtos/file.dto.js";

export interface FileRepository {
  create(data: CreateFileData): Promise<PrismaFile>;
  findById(id: string): Promise<PrismaFile | null>;
}
