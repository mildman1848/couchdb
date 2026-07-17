# Changelog

## 3.5.2.1-mldm1

- Initial Mildman1848 CouchDB image based on `ghcr.io/linuxserver/baseimage-debian:bookworm`.
- Uses Alpine `couchdb` package `3.5.2.1-r0`.
- Adds s6-overlay service supervision.
- Adds `/config` persistence.
- Adds optional `FILE__COUCHDB_PASSWORD` support.
- Adds local smoke test for health, auth, wrong-password rejection, `abc` process user, and secret leak checks.
