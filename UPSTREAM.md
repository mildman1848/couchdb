# Upstream

- Project: Apache CouchDB
- Source: https://github.com/apache/couchdb
- Docker packaging reference: https://github.com/apache/couchdb-docker
- Debian package repository: https://couchdb.apache.org/repo/
- License: Apache-2.0
- Packaged version: 3.5.2.1

## Packaging decision

Alpine does not currently provide a CouchDB package in Alpine 3.22, 3.23, 3.24, or edge. Building CouchDB from source would require Erlang/Elixir/SpiderMonkey and would add unnecessary maintenance burden.

This image therefore uses `ghcr.io/linuxserver/baseimage-debian:bookworm` and installs CouchDB from the official Apache CouchDB Debian repository with GPG verification.
