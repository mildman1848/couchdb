#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail=0

while IFS= read -r -d '' file; do
  case "$file" in
    */dependencies.d/*|*/contents.d/*|*/.gitkeep)
      continue
      ;;
  esac
  if [[ ! -s "$file" ]]; then
    echo "ERROR: empty file: $file" >&2
    fail=1
  fi
done < <(find . -type f \
  ! -path './.git/*' \
  ! -path './config/*' \
  ! -path './secrets/*' \
  -print0)

check_world_executable() {
  local file="$1"
  local mode
  mode="$(stat -c '%a' "$file")"
  if (( (8#$mode & 0005) != 0005 )); then
    echo "ERROR: runtime script must be readable/executable by abc (suggest 0755): $file mode=$mode" >&2
    fail=1
  fi
}

if [[ -d root/etc/s6-overlay/s6-rc.d ]]; then
  while IFS= read -r -d '' service_dir; do
    name="$(basename "$service_dir")"
    [[ "$name" == "user" || "$name" == "user2" || "$name" == "dependencies.d" || "$name" == "contents.d" ]] && continue
    if [[ ! -f "$service_dir/type" ]]; then
      echo "ERROR: missing type in $service_dir" >&2
      fail=1
      continue
    fi
    type_value="$(cat "$service_dir/type" 2>/dev/null || true)"
    case "$type_value" in
      oneshot)
        [[ -f "$service_dir/up" || -f "$service_dir/run" ]] || { echo "ERROR: oneshot without up/run: $service_dir" >&2; fail=1; }
        [[ ! -f "$service_dir/run" || -x "$service_dir/run" ]] || { echo "ERROR: oneshot run is not executable: $service_dir/run" >&2; fail=1; }
        ;;
      longrun)
        [[ -x "$service_dir/run" ]] || { echo "ERROR: longrun without executable run: $service_dir" >&2; fail=1; }
        check_world_executable "$service_dir/run"
        ;;
      bundle)
        ;;
      *)
        echo "ERROR: unknown s6 type '$type_value' in $service_dir" >&2
        fail=1
        ;;
    esac
  done < <(find root/etc/s6-overlay/s6-rc.d -mindepth 1 -maxdepth 1 -type d -print0)
fi

if [[ -d root/usr/local/bin ]]; then
  while IFS= read -r -d '' file; do
    case "$file" in
      */start-*|*/app-*|*/healthcheck|*/dummy-*|*/file-env)
        [[ -x "$file" ]] || { echo "ERROR: runtime helper is not executable: $file" >&2; fail=1; }
        check_world_executable "$file"
        ;;
    esac
  done < <(find root/usr/local/bin -maxdepth 1 -type f -print0)
fi

if command -v hadolint >/dev/null 2>&1; then
  find . -name 'Dockerfile*' ! -path './.git/*' -print0 | xargs -0 -r hadolint -c .hadolint.yaml
else
  echo "ERROR: hadolint not installed" >&2
  fail=1
fi

exit "$fail"
