# syntax=docker/dockerfile:1.7
ARG DEBIAN_SUITE=trixie
ARG LSIO_BASE_VERSION=trixie
FROM ghcr.io/linuxserver/baseimage-debian:${LSIO_BASE_VERSION}

ARG DEBIAN_SUITE
ARG LSIO_BASE_VERSION
ARG APP_VERSION=3.5.2.1
ARG IMAGE_REVISION=mldm1
ARG VERSION=3.5.2.1-mldm1

ENV APP_VERSION="${APP_VERSION}" \
    IMAGE_REVISION="${IMAGE_REVISION}" \
    VERSION="${VERSION}" \
    DEBIAN_SUITE="${DEBIAN_SUITE}"

LABEL org.opencontainers.image.title="CouchDB" \
      org.opencontainers.image.description="Apache CouchDB container image with LSIO-style s6 supervision and /config persistence" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/mildman1848/couchdb" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.base.name="ghcr.io/linuxserver/baseimage-debian:${LSIO_BASE_VERSION}" \
      build_version="Mildman1848 version:- ${VERSION} Upstream:- ${APP_VERSION} Revision:- ${IMAGE_REVISION}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    couchdb_repo_fingerprint="390EF70BB1EA12B2773962950EE62FB37A00258D"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      curl \
      dirmngr \
      gnupg \
      jq \
      procps; \
    export GNUPGHOME="$(mktemp -d)"; \
    curl -fsSL https://couchdb.apache.org/repo/keys.asc -o /tmp/couchdb-keys.asc; \
    gpg --batch --import /tmp/couchdb-keys.asc; \
    gpg --batch --export "${couchdb_repo_fingerprint}" > /usr/share/keyrings/couchdb-archive-keyring.gpg; \
    gpgconf --kill all || true; \
    rm -rf "${GNUPGHOME}" /tmp/couchdb-keys.asc; \
    echo "deb [signed-by=/usr/share/keyrings/couchdb-archive-keyring.gpg] https://apache.jfrog.io/artifactory/couchdb-deb/ ${DEBIAN_SUITE} main" > /etc/apt/sources.list.d/couchdb.list; \
    apt-get update; \
    echo "couchdb couchdb/mode select none" | debconf-set-selections; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends --allow-downgrades --allow-remove-essential --allow-change-held-packages \
      "couchdb=${APP_VERSION}~${DEBIAN_SUITE}"; \
    rm -f /opt/couchdb/etc/default.d/10-filelog.ini; \
    mkdir -p /config/data /config/log /config/etc/local.d; \
    rm -rf /opt/couchdb/data /opt/couchdb/var/log; \
    ln -s /config/data /opt/couchdb/data; \
    ln -s /config/log /opt/couchdb/var/log; \
    chmod 777 /opt/couchdb/etc/local.d; \
    apt-get purge -y --auto-remove dirmngr gnupg || true; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY root/ /

RUN set -eux; \
    chmod +x /usr/local/bin/start-app /usr/local/bin/file-env /usr/local/bin/healthcheck /usr/local/bin/app-healthcheck; \
    find /etc/s6-overlay/s6-rc.d -type f -name run -exec chmod +x {} \; || true; \
    find /etc/s6-overlay/s6-rc.d -type f -name up -exec chmod +x {} \; || true

VOLUME ["/config"]
EXPOSE 5984 4369 9100
HEALTHCHECK --interval=30s --timeout=5s --start-period=45s --retries=5 CMD ["/usr/local/bin/healthcheck"]
