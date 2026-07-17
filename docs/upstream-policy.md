# Upstream Policy

This template is inspired by LinuxServer.io container patterns, but it is not an official LinuxServer.io project.

## What we reuse conceptually

- LinuxServer.io baseimages where practical.
- s6-overlay v3 service layout.
- `/config` as the persistent configuration/data entry point.
- `PUID`, `PGID`, `TZ`, and `FILE__`-style secret conventions.
- Multi-architecture Buildx publishing.

## What we intentionally do differently

- Image repositories are small and standalone.
- Publishing to GitLab and Codeberg-compatible registries is optional and delayed until local smoke tests pass.
- Database images use Alpine packages inside the LSIO base initially, because wrapping official database images into an LSIO/s6 runtime is less predictable.

## Update policy

- Update GitHub Actions via Dependabot.
- Monitor LSIO baseimage tags and upstream application/package versions.
- Prefer upstream packages/artifacts when they are compatible with the target runtime.
- Document every non-trivial divergence in each image repository's `UPSTREAM.md`.
