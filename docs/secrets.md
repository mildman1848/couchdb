# Secrets

CouchDB can run without authentication, but this image supports password authentication through LSIO-style `FILE__` variables.

## Generate local password

```bash
make secrets
```

This writes:

```text
secrets/couchdb_password.txt
```

Properties:

- generated with Python `secrets` / OS CSPRNG
- default length: 96 alphanumeric characters
- file mode: `0600`
- value is never printed to stdout
- existing file is not overwritten unless `FORCE=1`

## Rotate

```bash
make secrets-rotate FORCE=1
```

## Runtime usage

```yaml
environment:
  FILE__COUCHDB_PASSWORD: /run/secrets/couchdb_password
volumes:
  - ./secrets/couchdb_password.txt:/run/secrets/couchdb_password:ro
```

At container start, `/usr/local/bin/start-app` sources `/usr/local/bin/file-env`, reads the secret, and writes `/config/couchdb-auth.conf` with mode `0600`. The password is not passed as a CouchDB command-line argument.
