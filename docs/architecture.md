# Architecture

## Core decision

Use LinuxServer.io baseimages as the runtime foundation and s6-overlay v3 as the process supervisor.

We do **not** set `USER abc` in final LSIO-based Dockerfiles. `/init` and s6 init stages need root privileges.

Service wrappers also do **not** immediately drop to `abc`: the app start script may need to create/chown runtime directories first. The final long-running database/application process must drop privileges with `s6-setuidgid abc`.

## Standard container flow

```text
/init
  └── s6-overlay v3
      ├── init-branding      oneshot
      ├── init-secrets       oneshot validation/logging only
      ├── init-app-config    oneshot base directory prep
      └── app service        longrun start script
             ├── source /usr/local/bin/file-env
             ├── create/chown runtime dirs as root
             └── exec actual app as abc
```

## Standard directories

| Path | Purpose |
|---|---|
| `/app` | application/runtime files |
| `/config` | persistent config |
| `/data` | persistent data if separate from `/config` |
| `/defaults` | read-only default config copied on first start |
| `/var/run/s6/...` | s6 runtime internals |

## Secrets

Support LinuxServer.io-style `FILE__` variables:

```yaml
environment:
  FILE__POSTGRES_PASSWORD: /run/secrets/postgres_password
```

Important s6 note: exporting variables in a oneshot does **not** persist into later longruns. Therefore start scripts source `/usr/local/bin/file-env` directly before reading secrets.

## Upstream usage policy

Prefer in this order:

1. Upstream official binary/package inside LSIO runtime, if compatible.
2. Distro package from Alpine/Ubuntu inside LSIO runtime, if upstream image cannot be cleanly reused.
3. Multi-stage copy from upstream official image, only if ABI/libc compatibility is safe.
4. Full source build, only when required.

For PostgreSQL and MariaDB pilots, the initial template uses Alpine packages inside the LSIO Alpine base because wrapping official database images into an s6/LSIO runtime is more fragile than useful.


## Current LSIO Alpine 3.24 platform signal

`ghcr.io/linuxserver/baseimage-debian:bookworm` currently builds successfully for `linux/amd64` and `linux/arm64` in CI. `linux/arm/v7` fails with `no match for platform in manifest`, so 32-bit Raspberry Pi support must remain best-effort until a compatible base image is selected.
