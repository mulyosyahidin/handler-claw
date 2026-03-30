# ============================================================
# Stage 1: deps — Install production dependencies only
# ============================================================
FROM node:22-alpine AS deps

WORKDIR /app

# Enable corepack untuk pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy manifests untuk layer caching
COPY package.json pnpm-lock.yaml ./

# Install hanya dependencies produksi
RUN pnpm install --frozen-lockfile --prod

# ============================================================
# Stage 2: builder — Compile TS & Generate Prisma Client
# ============================================================
FROM node:22-alpine AS builder

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy konfigurasi dan source
COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src

# Generate Prisma Client & Build TypeScript
RUN pnpm prisma generate
RUN pnpm build
# Build Prisma Seeder explicitly to dist/prisma/seed.js
RUN npx tsc -p prisma/tsconfig.json

# ============================================================
# Stage 3: runner — Minimal production image
# ============================================================
FROM node:22-alpine AS runner

# 1. Install dependencies sistem (netcat) sebagai root
RUN apk add --no-cache netcat-openbsd

WORKDIR /app
ENV NODE_ENV=production

# 2. Setup User & Permissions
RUN mkdir -p /app/public/uploads && chown -R node:node /app/public

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist
COPY --from=builder --chown=node:node /app/prisma ./prisma
COPY --from=builder --chown=node:node /app/src/lib/generated/prisma ./src/lib/generated/prisma
COPY --chown=node:node package.json ./

# Copy entrypoint
COPY --chown=node:node --chmod=755 docker/prod/entrypoint.sh ./entrypoint.sh

# 3. Jalankan sebagai user non-root
USER node

EXPOSE 3000

ENTRYPOINT ["./entrypoint.sh"]
