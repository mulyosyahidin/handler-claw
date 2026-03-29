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
  "image/jpeg": ".jpg",
  "image/jpg": ".jpg",
  "image/png": ".png",
  "image/webp": ".webp",
  "image/gif": ".gif",
};

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
