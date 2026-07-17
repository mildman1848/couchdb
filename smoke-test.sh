#!/usr/bin/env bash
set -euo pipefail

DOCKER_BIN="${DOCKER:-docker}"
IMAGE_REF="${IMAGE_REF:-ghcr.io/mildman1848/couchdb:3.5.2.1-mldm1}"
name="${CONTAINER_NAME:-couchdb-smoke}"
tmpdir="$(mktemp -d)"
password='couchdb-smoke-password-1234567890'
secret='couchdb-smoke-secret-1234567890'
cookie='couchdb-smoke-cookie-1234567890'

cleanup() {
  ${DOCKER_BIN} rm -f "$name" >/dev/null 2>&1 || true
  if command -v sudo >/dev/null 2>&1; then
    sudo rm -rf "$tmpdir" >/dev/null 2>&1 || rm -rf "$tmpdir" >/dev/null 2>&1 || true
  else
    rm -rf "$tmpdir" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

printf '%s' "$password" > "$tmpdir/couchdb_password"
printf '%s' "$secret" > "$tmpdir/couchdb_secret"
printf '%s' "$cookie" > "$tmpdir/couchdb_erlang_cookie"
chmod 600 "$tmpdir"/*

${DOCKER_BIN} rm -f "$name" >/dev/null 2>&1 || true
${DOCKER_BIN} run -d \
  --name "$name" \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/Berlin \
  -e COUCHDB_USER=admin \
  -e FILE__COUCHDB_PASSWORD=/run/secrets/couchdb_password \
  -e FILE__COUCHDB_SECRET=/run/secrets/couchdb_secret \
  -e FILE__COUCHDB_ERLANG_COOKIE=/run/secrets/couchdb_erlang_cookie \
  -v "$tmpdir:/run/secrets:ro" \
  "$IMAGE_REF" >/dev/null

for _ in {1..90}; do
  status="$(${DOCKER_BIN} inspect "$name" --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' 2>/dev/null || true)"
  [[ "$status" == healthy ]] && break
  sleep 2
done

status="$(${DOCKER_BIN} inspect "$name" --format '{{.State.Health.Status}}')"
if [[ "$status" != healthy ]]; then
  ${DOCKER_BIN} logs "$name" >&2 || true
  echo "ERROR: CouchDB container did not become healthy; status=$status" >&2
  exit 1
fi

${DOCKER_BIN} exec "$name" curl -fsS http://127.0.0.1:5984/_up | jq -e '.status == "ok"' >/dev/null
${DOCKER_BIN} exec "$name" curl -fsS -u "admin:${password}" http://127.0.0.1:5984/_membership | jq -e '.all_nodes | length >= 1' >/dev/null

wrong_output="$(${DOCKER_BIN} exec "$name" curl -fsS -u 'admin:wrong-password' http://127.0.0.1:5984/_membership 2>&1 || true)"
if grep -q 'all_nodes' <<<"$wrong_output"; then
  echo 'ERROR: CouchDB accepted a deliberately wrong password' >&2
  exit 1
fi

process_users="$(${DOCKER_BIN} exec "$name" sh -lc "ps -eo user,args | awk '/beam.smp|couchdb/ && !/awk/ {print \$1}' | sort -u")"
abc_uid="$(${DOCKER_BIN} exec "$name" sh -lc 'id -u abc')"
if ! grep -Eq "^(abc|${abc_uid})$" <<<"$process_users"; then
  echo "ERROR: CouchDB process did not run as abc; observed: $process_users" >&2
  exit 1
fi

logs="$(${DOCKER_BIN} logs "$name" 2>&1 || true)"
for value in "$password" "$secret" "$cookie"; do
  if grep -F "$value" <<<"$logs" >/dev/null; then
    echo 'ERROR: secret leaked in container logs' >&2
    exit 1
  fi
done

grep -q 'Mildman1848' <<<"$logs" || { echo 'ERROR: branding banner missing' >&2; exit 1; }
if grep -qi 'milde' <<<"$logs"; then
  echo 'ERROR: private branding leaked in logs' >&2
  exit 1
fi

echo 'CouchDB smoke test passed: health, auth, wrong-password rejection, abc process user, no secret leak'
