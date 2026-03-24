# HandlerClaw API

Backend API for HandlerClaw project built with Express.js, TypeScript, and Prisma.

## Tech Stack

- **Runtime:** Node.js (ES Modules)
- **Framework:** Express 5.x
- **Database:** PostgreSQL 17 (Prisma ORM)
- **Authentication:** JWT (jose)
- **Validation:** Zod
- **Logging:** Winston

---

## Getting Started (Development)

### 1. Prerequisites

- Node.js (v20+ recommended)
- `pnpm` (recommended) or `npm`
- Docker (for database)

### 2. Environment Setup

Copy the example environment file and fill in the values:

```bash
cp .env.example .env
```

Default `DATABASE_URL` for local development (if using Docker Compose):
`postgresql://uclaw:FXywBb3ehGmz1Alj@localhost:5432/db_handler_claw_dev?schema=public`

### 3. Spin up Database

Use Docker Compose to start the PostgreSQL instance:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

### 4. Install Dependencies

```bash
pnpm install
```

### 5. Database Migration & Seeding

```bash
# Generate Prisma Client
pnpm db:generate

# Run Migrations
pnpm db:migrate

# Seed Initial Data
pnpm db:seed
```

### 6. Run Development Server

```bash
pnpm dev
```

The API will be available at `http://localhost:3000`.

---

## API Documentation

Interactive API documentation is provided by **Scalar** and is automatically generated from Zod schemas.

- **URL:** `http://localhost:3000/docs`
- **Authentication:** Protected by Basic Auth. Use credentials defined in `DOCS_USERNAME` and `DOCS_PASSWORD`.
- **Implementation:** Uses `@asteasolutions/zod-to-openapi` to bridge Zod validation schemas with OpenAPI specifications.
- **Maintenance:** To add new routes to the documentation, register them in `src/lib/openapi-registry.ts`.

---

## Production Deployment

> [!CAUTION]
> **Source of Truth:** GitHub Actions is the **only** source of truth for deployment.
> **DO NOT** manually modify files, environment variables, or docker containers directly on the VPS. Manual changes will cause configuration drift and will be overwritten or cause failures in the next CI/CD pipeline run.

### 1. Environment Setup

Ensure `.env.production` is created with secure credentials.

### 2. Docker Deployment

This project uses a Blue-Green deployment strategy.

```bash
# Build and run containers
docker-compose up -d --build
```

The production setup includes:

- `db`: PostgreSQL 17
- `api_blue`: Primary instance
- `api_green`: Secondary instance for zero-downtime updates

### 3. Database Management (Production)

Run migrations on the production database:

```bash
pnpm db:deploy
```

---

## Testing Production Setup Locally

You can test the production-ready Docker setup on your local machine before real deployment.

### 1. Build Docker Image

Build the API image with a tag that matches the one in `docker-compose.yml`:

```bash
# Get DOCKERHUB_USERNAME from .env.production or set it manually
export DOCKERHUB_USERNAME=yourusername

docker build -t ${DOCKERHUB_USERNAME}/handler-claw-api:latest .
```

### 2. Setup Production Environment

Create `.env.production` based on the example:

```bash
cp .env.production.example .env.production
```

_Note: Ensure `DATABASE_URL` points to the `db` service (e.g., `postgresql://user:password@db:5432/...`)._

### 3. Create Network

The production `docker-compose.yml` expects an external network named `internal`:

```bash
docker network create internal
```

### 4. Run the Stack

Start all services (Database and Blue-Green API instances):

```bash
docker-compose up -d
```

### 5. Verify Deployment

Check the status of the containers:

```bash
docker-compose ps
```

The API should be accessible through the health check endpoint:

```bash
curl http://localhost:3000/api/health-check
```

_(Note: You might need a Load Balancer or Nginx in front of blue/green instances to access them via a single port in a real production scenario)._

---

## CI/CD Configuration (GitHub Actions)

This project uses GitHub Actions for automated Blue-Green deployment. Ensure the following Secrets and Variables are configured in your GitHub Repository settings (**Settings > Secrets and variables > Actions**).

### GitHub Actions Secrets

| Secret Name             | Description                                                                    |
| :---------------------- | :----------------------------------------------------------------------------- |
| `DATABASE_URL`          | Full PostgreSQL connection string (e.g. `postgresql://user:pass@host:5432/db`) |
| `DB_PASSWORD`           | PostgreSQL password for the `db` container                                     |
| `JWT_SECRET`            | Secret key for signing JWT tokens                                              |
| `DOCS_PASSWORD`         | Password for API Documentation Basic Auth.                                     |
| `DEFAULT_USER_EMAIL`    | Email for the default user created during seeding.                             |
| `DEFAULT_USER_PASSWORD` | Password for the default user created during seeding.                          |
| `SSH_HOST`              | Remote server IP or Hostname                                                   |
| `SSH_USER`              | Remote server SSH username (e.g. `root` or `ubuntu`)                           |
| `SSH_PRIVATE_KEY`       | SSH Private Key used to connect to the server                                  |

### GitHub Actions Variables

| Variable Name       | Description                                                                     |
| :------------------ | :------------------------------------------------------------------------------ |
| `IMAGE_NAME`        | Name of the Docker image (e.g. `handler-claw-api`)                              |
| `DB_USER`           | PostgreSQL username                                                             |
| `DB_NAME`           | PostgreSQL database name                                                        |
| `DEPLOY_PATH`       | Absolute path on the server where the project is deployed (e.g. `/var/www/api`) |
| `DOCS_USERNAME`     | Username for API Documentation Basic Auth (default: `admin`).                   |
| `DEFAULT_USER_NAME` | Full name for the default user created during seeding.                          |
| `APP_PORT`          | (Optional) Application port (Default: `3000`)                                   |
| `LOG_LEVEL`         | (Optional) Winston log level (Default: `info`)                                  |

---

## Available Scripts

- `pnpm dev`: Start development server with hot-reload (`tsx watch`).
- `pnpm build`: Compile TypeScript to JavaScript in `dist/`.
- `pnpm start`: Run the compiled production build.
- `pnpm lint`: Run ESLint check.
- `pnpm format`: Format code with Prettier.
- `pnpm db:studio`: Open Prisma Studio to explore data.
- `pnpm db:migrate`: Create and run migrations in development.
- `pnpm db:seed`: Seed the database with initial data.

## Project Structure

- `src/index.ts`: Entry point.
- `src/app.ts`: Express application configuration.
- `src/controller/`: Request handlers.
- `src/service/`: Business logic.
- `src/route/`: Route definitions.
- `src/middleware/`: Express middlewares (Auth, Logger, etc.).
- `src/lib/`: Library configurations and shared schemas.
- `prisma/`: Database schema and migrations.
