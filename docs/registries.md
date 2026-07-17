# Registry Publishing and Git Mirrors

Publishing and mirroring are separate concerns.

## Git mirrors

This template includes the current `mirror.yml` workflow:

```text
GitHub main/tags → Codeberg main/tags
GitHub main/tags → GitLab main/tags
```

Required GitHub repository secrets:

```text
CODEBERG_MIRROR_SSH_KEY
GITLAB_MIRROR_SSH_KEY
```

These are private SSH keys used only by the mirror workflow. Do not print them, commit them, or reuse them as application secrets.

## Container registries

| Registry | Status | Image pattern |
|---|---|---|
| GHCR | prepared | `ghcr.io/mildman1848/<image>` |
| Docker Hub | prepared when `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` exist | `docker.io/<DOCKERHUB_USERNAME>/<image>` |
| GitLab Registry | optional | `registry.gitlab.com/mildman1848/<image>` |
| Codeberg/Forgejo Registry | optional, verify exact package path before first push | `codeberg.org/mildman1848/<image>` |

## Registry secrets

Docker Hub:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

GitLab Registry:

```text
GITLAB_REGISTRY_USER
GITLAB_REGISTRY_TOKEN
```

Codeberg/Forgejo Registry:

```text
CODEBERG_REGISTRY_USER
CODEBERG_REGISTRY_TOKEN
```

## Safety policy

- Pull requests build but do not push.
- Manual `workflow_dispatch` with `push=true` is required for publishing.
- Local lint/build/smoke/security checks must pass before registry push.
- Git mirrors may run automatically after pushes to `main` because they copy Git state only; registry publishing creates public artifacts and stays explicit.
