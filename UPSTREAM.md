# Upstream

- Project: Apache CouchDB
- Source: https://github.com/apache/couchdb
- Docker packaging reference: https://github.com/apache/couchdb-docker
- Debian package repository: https://couchdb.apache.org/repo/
- License: Apache-2.0
- Packaged version: 3.5.2.1

## Repository model

This repository is **not** a source fork of Apache CouchDB. It is a standalone LSIO-style packaging repository.

It contains:

- Dockerfile and OCI metadata
- s6-overlay service definitions
- `/config` persistence wiring
- `PUID`, `PGID`, `TZ`, and `FILE__` secret conventions
- CI, smoke tests, SBOM/security helpers, and documentation

It does **not** carry or patch CouchDB application source code. A full Git fork of `apache/couchdb` would add unnecessary maintenance overhead unless we start carrying source-level CouchDB patches.

## Packaging decision

Alpine does not currently provide a CouchDB package in Alpine 3.22, 3.23, 3.24, or edge. Building CouchDB from source would require Erlang/Elixir/SpiderMonkey and would add unnecessary maintenance burden.

This image therefore uses `ghcr.io/linuxserver/baseimage-debian:trixie` and installs CouchDB from the official Apache CouchDB Debian repository with GPG verification.

## Divergence from official upstream images

- Runtime supervision is provided by s6-overlay v3.
- Persistent data lives under `/config`.
- Secrets can be mounted through `FILE__*` environment variables.
- The main process runs as the LSIO-style `abc` user after initialization.
- Multi-registry publishing and local smoke tests follow the Mildman1848 Docker image template conventions.

## Update tracking

Upstream status is tracked by `.github/workflows/upstream-monitor.yml`.

Manual check:

```bash
make check-upstream DOCKER='sudo docker'
```

The workflow and manual target check:

1. the pinned LSIO Debian base tag,
2. the configured Debian suite,
3. the current CouchDB package candidate from the official Apache CouchDB Debian repository,
4. whether the package candidate differs from the pinned `APP_VERSION`.

When a newer CouchDB package is available:

1. Review upstream release notes and security advisories.
2. Update `APP_VERSION` in `Makefile`, `Dockerfile`, and workflows.
3. Reset `IMAGE_REVISION` to `mldm1` for a new upstream version.
4. Run `make validate`, `make build DOCKER='sudo docker'`, and `make smoke DOCKER='sudo docker'`.
5. Generate/refresh SBOM and security scan artifacts before publishing.

## Branch policy

A three-branch source-fork model is not required for this repository while CouchDB itself is consumed from the Apache Debian package repository.

Use `main` for the releaseable packaging state. If source-level CouchDB patches ever become necessary, revisit this policy and introduce a real upstream mirror branch before carrying patches.
