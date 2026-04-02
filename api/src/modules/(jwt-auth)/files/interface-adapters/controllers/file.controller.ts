import type { Request, Response } from "express";
import { createSuccessResponse, createErrorResponse } from "../../../../../lib/types/response.js";
import { UploadFileUseCase } from "../../../../_shared/files/application/use-cases/upload-file.use-case.js";
import { getRelativePath } from "../../../../../utils/file-storage.js";
import logger from "../../../../../config/logger.js";

export class FileController {
  constructor(private uploadFileUseCase: UploadFileUseCase) {}

  upload = async (req: Request, res: Response) => {
    try {
      if (!req.file) {
        res
          .status(400)
          .json(createErrorResponse("File wajib diunggah", { file: "File is required" }));
        return;
      }

      // Multer already saved the file, now we save the metadata to DB
      const { filename, mimetype, size, path: filePath } = req.file;

      const relativePath = getRelativePath(filePath);

      const result = await this.uploadFileUseCase.execute({
        fileName: filename,
        fileType: mimetype,
        fileSize: size,
        filePath: relativePath,
      });

      res.status(201).json(createSuccessResponse("File berhasil diunggah", result));
    } catch (error: any) {
      logger.error("FileController::upload() Error:", error);
      res.status(500).json(createErrorResponse(error.message, { error: "Internal server error" }));
    }
  };
}
