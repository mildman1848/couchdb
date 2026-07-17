# Security and SBOM

This template adopts the useful security/SBOM ideas from the older `audiobookshelf` image work without copying its historical complexity.

## Local targets

| Target | Tool | Purpose |
|---|---|---|
| `make security-scan` | Trivy | Config scan plus image scan when the image exists locally. |
| `make trivy-scan` / `make scan` | Trivy | Image vulnerability scan. |
| `make sbom` | Syft | Generate a local SPDX JSON SBOM under `sbom/`. |

## CI policy

- Template repo: run Trivy config scan and verify Syft tooling.
- Image repos: build the image, run Trivy image scan, and optionally upload artifacts/SBOMs.
- SARIF upload is useful for public repos with code scanning enabled, but must not be required for private repos where GitHub can reject uploads.

## Secret policy

- Generate local secrets with `make secret`/`make secrets-generate`.
- Use 96-character CSPRNG values by default.
- Store generated files mode `0600`.
- Never print secret values to stdout, logs, CI summaries, or README examples.
- Support LSIO-style `FILE__` variables in derived images.

## LSIO-specific scanner notes

Trivy rule `DS-0002` recommends a final Dockerfile `USER`. For LSIO/s6 images this is intentionally not used: `/init` and s6 initialization need root, then the final long-running app process must drop to `abc` with `s6-setuidgid abc`. Treat this as a documented LSIO exception, not as permission to run the application as root.

When the local Docker socket requires sudo, image scanners need matching privileges:

```bash
make security-scan DOCKER='sudo docker' TRIVY='sudo trivy'
make sbom DOCKER='sudo docker' SYFT='sudo syft'
```

## Recommended image-repo checks

Database and service images should extend smoke tests beyond "container started":

- valid auth succeeds;
- deliberately wrong auth fails;
- final long-running process runs as `abc`;
- logs do not contain generated secret values;
- healthcheck proves application-level readiness, not just an open port.
