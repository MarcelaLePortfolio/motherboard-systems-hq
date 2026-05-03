#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

touch .gitignore

append_if_missing() {
  local pattern="$1"
  if ! grep -Fxq "$pattern" .gitignore; then
    printf '%s\n' "$pattern" >> .gitignore
  fi
}

append_if_missing ""
append_if_missing "# Phase 487 DB runtime sidefiles"
append_if_missing "db/*.db-wal"
append_if_missing "db/*.db-shm"
append_if_missing "db/*.sqlite-wal"
append_if_missing "db/*.sqlite-shm"

echo ".gitignore updated for DB sidefiles"
