#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

artifacts_dir=".artifacts"
mkdir -p "$artifacts_dir"

max_file_mb="${MAX_ARTIFACT_FILE_MB:-100}"
max_total_mb="${MAX_ARTIFACT_TOTAL_MB:-1024}"

bytes_per_mb=$((1024 * 1024))
max_file_bytes=$((max_file_mb * bytes_per_mb))
max_total_bytes=$((max_total_mb * bytes_per_mb))

status=0

is_exempt_artifact() {
  case "$1" in
    .artifacts/docker/*.tar) return 0 ;;
    *) return 1 ;;
  esac
}

while IFS= read -r -d '' file; do
  if is_exempt_artifact "$file"; then
    continue
  fi

  size_bytes="$(stat -f '%z' "$file")"
  if [ "$size_bytes" -gt "$max_file_bytes" ]; then
    echo "artifact file exceeds limit (${max_file_mb}MB): $file"
    status=1
  fi
done < <(find "$artifacts_dir" -type f -print0)

total_bytes="$(
  find "$artifacts_dir" -type f ! -path '.artifacts/docker/*.tar' -exec stat -f '%z' {} \; 2>/dev/null \
    | awk '{s+=$1} END {print s+0}'
)"

if [ "$total_bytes" -gt "$max_total_bytes" ]; then
  echo "artifact directory exceeds limit (${max_total_mb}MB): $artifacts_dir"
  status=1
fi

exit "$status"
