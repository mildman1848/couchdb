# Versioning

Images use an LSIO-inspired combined version: preserve the upstream application version and add a local packaging revision.

```text
<upstream-version>-mldm<N>
```

Examples:

```text
16.14-mldm1
11.8.8-mldm2
```

## Components

| Component | Meaning |
|---|---|
| `<upstream-version>` | Version from the upstream application/package. |
| `mldm<N>` | Local image packaging revision for that upstream version. |

`Mildman1848` is allowed as the public namespace/brand. Private household names must not appear in public artifacts.

## Bump rules

- Upstream package/application changes: bump `<upstream-version>` and reset to `mldm1`.
- Packaging-only changes with the same upstream version: increment `mldm<N>`.
- Security/baseimage-only rebuild that creates a republished artifact: increment `mldm<N>`.

## Labels

Derived repos should expose:

```text
org.opencontainers.image.version=<upstream-version>-mldm<N>
org.opencontainers.image.revision=<git-sha>
IMAGE_REVISION=mldm<N>
APP_VERSION=<upstream-version>
VERSION=<upstream-version>-mldm<N>
```

## Pitfall

Do not use shortened legacy variants of the packaging suffix. The project standard is explicitly `mldm<N>`.
