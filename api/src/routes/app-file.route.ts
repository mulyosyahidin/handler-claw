import { Router } from "express";
import multer from "multer";
import { getUploadDir, generateFilename } from "../utils/file-storage.js";
import { AppFileController } from "../modules/(api-key-auth)/files/interface-adapters/controllers/file.controller.js";
import { PrismaFileRepository } from "../modules/_shared/files/infrastructure/repositories/prisma-file.repository.js";
import { UploadFileUseCase } from "../modules/_shared/files/application/use-cases/upload-file.use-case.js";
import { apiKeyMiddleware } from "../middleware/api-key.middleware.js";
import { registry } from "../lib/openapi-registry.js";

const appFileRouter: Router = Router();

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
const appFileController = new AppFileController(uploadFileUseCase);

registry.registerPath({
  method: "post",
  path: "/api/app/files",
  summary: "Upload File (App)",
  description: "Mengunggah file ke server dan menyimpan metadatanya via API Key.",
  tags: ["App: Files"],
  security: [{ apiKeyAuth: [] }],
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
    401: { description: "API Key Unauthorized" },
  },
});

appFileRouter.post("/", apiKeyMiddleware, upload.single("file"), appFileController.upload);

export default appFileRouter;
