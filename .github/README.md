# GitHub Actions Workflows

This directory contains the CI/CD pipeline definitions for the HandlerClaw project.

## Workflows

### 1. Build and Deploy API (`api-deploy.yml`)
Triggered on every push to the `main` branch (or specific development branch as configured) when changes occur in the `api/` directory or the workflow files themselves.

#### Pipeline Stages:
1.  **Build & Push Docker Image**:
    *   Uses Docker Buildx for efficient building.
    *   Authenticates with GitHub Container Registry (GHCR).
    *   Builds and pushes the image tagged with `:latest` and the specific `:SHA`.
    *   Utilizes GitHub Actions cache (`gha`) to speed up subsequent builds.

2.  **Deploy to Server**:
    *   **Secure Transfer**: Copies `docker-compose.yml` to the production server via SCP.
    *   **Environment Injection**: Dynamically generates `.env.production` on the server using GitHub Secrets and Variables.
    *   **Security Hardening**: Immediately applies `chmod 600` to sensitive configuration files on the VPS.
    *   **Database Migration**: Runs `npx prisma migrate deploy` using a temporary container to ensure the schema is up-to-date before updating the application.
    *   **Blue-Green Deployment**:
        1.  Pull the latest image from GHCR.
        2.  Start/Update the **Green** instance first.
        3.  Wait and verify health status via a strict health-check loop (up to 75 seconds).
        4.  If **Green** is healthy, start/update the **Blue** instance.
        5.  Reload the **Nginx Proxy** (`proxy-nginx`) to route traffic to the updated instances.
        6.  Cleanup old dangling Docker images.

---

## Required Configuration

To run these workflows, ensure the following are set in GitHub Repository **Settings > Secrets and variables > Actions**:

### Repository Secrets (Sensitive)
| Secret Name | Description |
| :--- | :--- |
| `DATABASE_URL` | Full Prisma connection string. |
| `DB_PASSWORD` | Password for the PostgreSQL database container. |
| `JWT_SECRET` | Secret key for JWT signing. |
| `DOCS_PASSWORD` | Password for API Documentation Basic Auth. |
| `DEFAULT_USER_EMAIL` | Email for the default user created during seeding. |
| `DEFAULT_USER_PASSWORD` | Password for the default user created during seeding. |
| `SSH_HOST` | VPS IP address or hostname. |
| `SSH_USER` | SSH username for the VPS (e.g., `root`, `ubuntu`). |
| `SSH_PRIVATE_KEY` | Private key for SSH access. |
| `DEPLOY_PATH` | Absolute path on the VPS where the project resides (e.g., `/var/www/handler-claw`). |

### Repository Variables (Non-Sensitive)
| Variable Name | Description |
| :--- | :--- |
| `IMAGE_NAME` | Name of the Docker image (e.g., `handler-claw-api`). |
| `DB_USER` | PostgreSQL username. |
| `DB_NAME` | PostgreSQL database name. |
| `DOCS_USERNAME` | Username for API Documentation Basic Auth (default: `admin`). |
| `DEFAULT_USER_NAME` | Full name for the default user created during seeding (default: `Administrator`). |
| `APP_PORT` | Port the application listens on (default: `3000`). |
| `LOG_LEVEL` | Logging level for Winston (default: `info`). |

---

## Important Notes
*   **Source of Truth**: The GitHub Actions workflow is the **only** authorized method for updating the production environment. Manual changes on the VPS are strictly prohibited to avoid configuration drift.
*   **Health Checks**: The deployment will fail-fast and stop if the Green instance fails its health check, preventing the Blue instance (current stable) from being affected.
*   **Prisma Client**: The Dockerfile is optimized for Prisma, ensuring the client is generated during the build stage and included in the final production image.
