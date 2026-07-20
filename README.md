# CouchDB Container Image

Apache CouchDB packaged as a Mildman1848 container image with LSIO-style s6 supervision, `/config` persistence, `PUID`/`PGID`, and `FILE__` secret support.

## Image

```text
ghcr.io/mildman1848/couchdb:3.5.2.1-mldm1
```

## License

Apache CouchDB is licensed under the Apache License 2.0. This repository packages CouchDB from the official Apache CouchDB Debian repository and keeps Apache NOTICE/LICENSE obligations documented.

## Runtime

Required for first start:

| Variable | Purpose |
|---|---|
| `COUCHDB_USER` | Admin username, defaults to `admin` |
| `COUCHDB_PASSWORD` / `FILE__COUCHDB_PASSWORD` | Required admin password |
| `COUCHDB_SECRET` / `FILE__COUCHDB_SECRET` | Optional auth secret; generated under `/config/couchdb/secret` if absent |
| `COUCHDB_ERLANG_COOKIE` / `FILE__COUCHDB_ERLANG_COOKIE` | Optional Erlang cookie; generated under `/config/couchdb/erlang.cookie` if absent |

Persistent data lives under `/config`.

Ports:

| Port | Purpose |
|---:|---|
| `5984` | CouchDB HTTP API |
| `4369` | Erlang EPMD |
| `9100` | CouchDB/Erlang cluster communication |

## Compose example

```yaml
services:
  couchdb:
    image: ghcr.io/mildman1848/couchdb:3.5.2.1-mldm1
    container_name: couchdb
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: Europe/Berlin
      COUCHDB_USER: admin
      FILE__COUCHDB_PASSWORD: /run/secrets/couchdb_password
    volumes:
      - ./config:/config
    secrets:
      - couchdb_password
    ports:
      - "5984:5984"
    restart: unless-stopped

secrets:
  couchdb_password:
    file: ./secrets/couchdb_password
```

## Local validation

```bash
make validate
make build DOCKER='sudo docker'
make smoke DOCKER='sudo docker'
```

Trivy `DS-0002` is expected for LSIO-based images because `/init` must start as root; the CouchDB process itself is started via `s6-setuidgid abc`.

## Platform support

Default CI platforms are:

```text
linux/amd64,linux/arm64
```

The official Apache CouchDB Debian repository does not currently provide `armhf`/`linux/arm/v7` packages for Debian trixie, so 32-bit ARM is not included.
