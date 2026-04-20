#!/usr/bin/env bash
set -euo pipefail

: "${MB_ARTIFACT_DIR:=/tmp/motherboard-systems-hq-artifacts}"
mkdir -p "$MB_ARTIFACT_DIR"

artifact_path() {
  local name="$1"
  printf '%s/%s\n' "$MB_ARTIFACT_DIR" "$name"
}

safe_write() {
  local target="$1"
  shift
  "$@" > "$target"
}

safe_sample() {
  local target="$1"
  local lines="${2:-200}"
  shift 2
  "$@" | head -n "$lines" > "$target"
}

rotate_if_over() {
  local target="$1"
  local max_bytes="$2"

  if [ -f "$target" ]; then
    local size
    size="$(wc -c < "$target" | tr -d ' ')"
    if [ "$size" -gt "$max_bytes" ]; then
      mv "$target" "${target}.$(date '+%Y%m%d%H%M%S').rotated"
      : > "$target"
    fi
  fi
}

assert_not_repo_path() {
  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  local candidate="$1"

  case "$candidate" in
    "$repo_root"/*)
      echo "Refusing to use repo path for controlled artifact: $candidate" >&2
      return 1
      ;;
  esac
}
