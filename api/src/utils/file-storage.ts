import fs from "fs";
import path from "path";

export function getUploadDir(): string {
  const now = new Date();
  const year = now.getFullYear().toString();
  const month = (now.getMonth() + 1).toString().padStart(2, "0");
  const uploadDir = path.join(process.cwd(), "public", "uploads", year, month);

  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }

  return uploadDir;
}

export function generateFilename(originalname: string): string {
  const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
  const ext = path.extname(originalname);
  const baseName = path.basename(originalname, ext).replace(/\s+/g, "-");
  return `${baseName}-${uniqueSuffix}${ext}`;
}

export function getRelativePath(absolutePath: string): string {
  const publicPath = path.join(process.cwd(), "public");
  return absolutePath.replace(publicPath, "").replace(/\\/g, "/");
}

const MIME_EXTENSION_MAP: Record<string, string> = {
  // Images
  "image/jpeg": ".jpg",
  "image/jpg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp",
  "image/gif": ".gif",
  // Videos
  "video/mp4": ".mp4",
  "video/3gpp": ".3gp",
  "video/quicktime": ".mov",
  "video/webm": ".webm",
  // Audio
  "audio/mpeg": ".mp3",
  "audio/ogg": ".ogg",
  "audio/mp4": ".m4a",
  "audio/wav": ".wav",
  "audio/webm": ".webm",
  "audio/aac": ".aac",
  // Documents
  "application/pdf": ".pdf",
  "application/msword": ".doc",
  "application/vnd.openxmlformats-officedocument.wordprocessingml.document": ".docx",
  "application/vnd.ms-excel": ".xls",
  "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": ".xlsx",
  "application/vnd.ms-powerpoint": ".ppt",
  "application/vnd.openxmlformats-officedocument.presentationml.presentation": ".pptx",
  "application/zip": ".zip",
  "text/plain": ".txt",
};

export async function downloadRemoteMedia(url: string, originalPath?: string): Promise<string> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Gagal mengunduh media (${response.status}): ${response.statusText}`);
  }

  const buffer = await response.arrayBuffer();
  const mimetype = (
    response.headers.get("content-type") || "application/octet-stream"
  ).toLowerCase();

  // Extract extension from mimetype or original path
  let ext = MIME_EXTENSION_MAP[mimetype];
  if (!ext) {
    ext = path.extname(originalPath || url) || ".bin";
  }

  const filename = generateFilename(`wa-media${ext}`);
  const uploadDir = getUploadDir();
  const absolutePath = path.join(uploadDir, filename);

  fs.writeFileSync(absolutePath, Buffer.from(buffer));

  return getRelativePath(absolutePath);
}

export async function downloadExternalImage(url: string): Promise<{
  filename: string;
  mimetype: string;
  size: number;
  filePath: string;
}> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Gagal mengunduh gambar: ${response.statusText}`);
  }

  const buffer = await response.arrayBuffer();
  const mimetype = (response.headers.get("content-type") || "image/jpeg").toLowerCase();
  const size = buffer.byteLength;

  // Map mimetype to extension
  const ext = MIME_EXTENSION_MAP[mimetype] || ".jpg";

  // Use a cleaner name for external avatars
  const filename = generateFilename(`google-avatar${ext}`);

  const uploadDir = getUploadDir();
  const absolutePath = path.join(uploadDir, filename);

  fs.writeFileSync(absolutePath, Buffer.from(buffer));

  const relativePath = getRelativePath(absolutePath);

  return {
    filename,
    mimetype,
    size,
    filePath: relativePath,
  };
}
