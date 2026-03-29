import type { IFile } from "../../domain/entities/file.entity.js";

export type UploadFileResponse = {
  file: IFile;
};

export type UploadFileRequest = {
  fileName: string;
  fileType: string;
  fileSize: number;
  filePath: string;
};

/**
 * Repository Data Contracts
 */
export type CreateFileData = {
  fileName: string;
  fileType: string;
  fileSize: number;
  filePath: string;
};
