# Make Targets

This repository follows the Mildman1848 LSIO-style image Make surface.

## Common targets

| Target | Purpose |
|---|---|
| `make info` | Print image metadata and build variables. |
| `make lint` | Run static repository/Dockerfile/s6 checks. |
| `make validate` | Run lint, environment validation, and workflow validation. |
| `make build DOCKER='sudo docker'` | Build the local `linux/amd64` image with Buildx `--load`. |
| `make smoke DOCKER='sudo docker'` | Run the CouchDB smoke test against the local image. |
| `make secrets` | Generate `secrets/couchdb_password.txt` without printing it. |
| `make start DOCKER='sudo docker'` | Start a local dev container. |
| `make stop DOCKER='sudo docker'` | Remove the local dev container. |
| `make logs DOCKER='sudo docker'` | Show dev container logs. |
| `make scan DOCKER='sudo docker' TRIVY='sudo trivy'` | Run Trivy image scan. |
| `make sbom DOCKER='sudo docker' SYFT='sudo syft'` | Generate an SBOM. |
| `make check-upstream DOCKER='sudo docker'` | Show base image/package signal. |
| `make release-dry-run` | Print release metadata without publishing. |

## Defaults

| Variable | Value |
|---|---|
| `IMAGE_NAME` | `couchdb` |
| `APP_VERSION` | `3.5.2.1` |
| `IMAGE_REVISION` | `mldm1` |
| `VERSION` | `3.5.2.1-mldm1` |
| `REGISTRY` | `ghcr.io/mildman1848` |
| `PLATFORMS` | `linux/amd64,linux/arm64` |
| `COUCHDB_PASSWORD_FILE` | `secrets/couchdb_password.txt` |

## Notes

Use `DOCKER='sudo docker'` on hosts where the Docker socket requires elevated access.
