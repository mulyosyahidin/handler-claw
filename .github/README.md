# GitHub Actions Workflows

This directory contains the CI/CD pipeline definitions for the HandlerClaw project.

## Workflows

### 1. Build and Deploy API (`api-deploy.yml`)
Triggered on every push to the `development` branch when changes occur in the `api/` directory or the workflow files themselves.

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

### 2. Build & Distribute Android (APK) (`android-release.yml`)
Triggered on every push to the `development` branch when changes occur in the `handlerclaw/` directory or the workflow files themselves. Can also be triggered manually via `workflow_dispatch`.

#### Pipeline Stages:
1.  **Environment Setup**:
    *   Sets up **Java 24** (Temurin distribution).
    *   Sets up **Flutter 3.41.4** with caching enabled.
2.  **Build**:
    *   Fetches Flutter dependencies.
    *   Builds a release APK with `API_BASE_URL` injected via `--dart-define`.
3.  **Distribution**:
    *   Distributes the APK to **Firebase App Distribution** for the configured group.
    *   Uses a service account for secure authentication.
4.  **Artifacts**:
    *   Uploads the generated `app-release.apk` as a GitHub Action artifact (retrained for 7 days).

---

## Required Configuration

To run these workflows, ensure the following are set in GitHub Repository **Settings > Secrets and variables > Actions**:

### Repository Secrets (Sensitive)
| Secret Name | Description | Used By |
| :--- | :--- | :--- |
| `DATABASE_URL` | Full Prisma connection string. | API |
| `DB_PASSWORD` | Password for the PostgreSQL database container. | API |
| `JWT_SECRET` | Secret key for JWT signing. | API |
| `DOCS_PASSWORD` | Password for API Documentation Basic Auth. | API |
| `DEFAULT_USER_EMAIL` | Email for the default user created during seeding. | API |
| `DEFAULT_USER_PASSWORD` | Password for the default user created during seeding. | API |
| `FIREBASE_PRIVATE_KEY` | Private key for Firebase Admin SDK. | API |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Firebase Service Account JSON for distribution. | Android |
| `SSH_HOST` | VPS IP address or hostname. | API |
| `SSH_USER` | SSH username for the VPS (e.g., `root`, `ubuntu`). | API |
| `SSH_PRIVATE_KEY` | Private key for SSH access. | API |
| `DEPLOY_PATH` | Absolute path on the VPS where the project resides. | API |

### Repository Variables (Non-Sensitive)
| Variable Name | Description | Used By |
| :--- | :--- | :--- |
| `IMAGE_NAME` | Name of the Docker image (e.g., `handler-claw-api`). | API |
| `DB_USER` | PostgreSQL username. | API |
| `DB_NAME` | PostgreSQL database name. | API |
| `DOCS_USERNAME` | Username for API Documentation Basic Auth. | API |
| `DEFAULT_USER_NAME` | Full name for the default user created during seeding. | API |
| `APP_PORT` | Port the application listens on (default: `3000`). | API |
| `LOG_LEVEL` | Logging level for Winston (default: `info`). | API |
| `FIREBASE_PROJECT_ID` | Project ID for Firebase. | API |
| `FIREBASE_CLIENT_EMAIL` | Client email for Firebase Admin SDK. | API |
| `API_BASE_URL` | Base URL for the API (used in Flutter build). | Android |
| `FIREBASE_APP_ID` | Firebase App ID for the Android application. | Android |
| `FIREBASE_GROUP` | Firebase tester group for distribution. | Android |

---

## Important Notes
*   **Source of Truth**: The GitHub Actions workflow is the **only** authorized method for updating the production environment. Manual changes on the VPS are strictly prohibited.
*   **Health Checks**: The API deployment will fail-fast and stop if the Green instance fails its health check, protecting the current stable instance.
*   **Flutter Distribution**: The Android pipeline automates the distribution to testers, ensuring they always have the latest build from the `development` branch.
