import { Router } from "express";
import multer from "multer";
import { getUploadDir, generateFilename } from "../utils/file-storage.js";
import { FileController } from "../modules/files/interface-adapters/controllers/file.controller.js";
import { PrismaFileRepository } from "../modules/files/infrastructure/repositories/prisma-file.repository.js";
import { UploadFileUseCase } from "../modules/files/application/use-cases/upload-file.use-case.js";
import { authMiddleware } from "../middleware/index.js";
import { registry } from "../lib/openapi-registry.js";

const fileRouter: Router = Router();

// Storage Configuration
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, getUploadDir());
  },
  filename: (_req, file, cb) => {
    cb(null, generateFilename(file.originalname));
  },
});

const upload = multer({ storage });

// Infrastructure Layer
const fileRepository = new PrismaFileRepository();

// Application Layer (Use Cases)
const uploadFileUseCase = new UploadFileUseCase(fileRepository);

// Interface Adapters Layer (Controller)
const fileController = new FileController(uploadFileUseCase);

registry.registerPath({
  method: "post",
  path: "/api/files",
  summary: "Upload File",
  description: "Mengunggah file ke server dan menyimpan metadatanya.",
  tags: ["Files"],
  security: [{ bearerAuth: [] }],
  request: {
    body: {
      content: {
        "multipart/form-data": {
          schema: {
            type: "object",
            properties: {
              file: { type: "string", format: "binary" },
            },
            required: ["file"],
          },
        },
      },
    },
  },
  responses: {
    201: { description: "File berhasil diunggah" },
    400: { description: "File wajib diunggah" },
    401: { description: "Unauthorized" },
  },
});

fileRouter.post("/", authMiddleware, upload.single("file"), fileController.upload);

export default fileRouter;
