#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

touch .gitignore

TMP_FILE="$(mktemp)"
cp .gitignore "$TMP_FILE"

append_if_missing() {
  local pattern="$1"
  if ! grep -Fxq "$pattern" .gitignore; then
    printf '%s\n' "$pattern" >> .gitignore
  fi
}

append_if_missing ""
append_if_missing "# Phase 487 volatile docs runtime outputs"
append_if_missing "docs/phase487_*probe_output.txt"
append_if_missing "docs/phase487_*live_probe_output.txt"
append_if_missing "docs/phase487_*surface_probe_output.txt"
append_if_missing "docs/phase487_*audit_output.txt"

if cmp -s "$TMP_FILE" .gitignore; then
  echo "No .gitignore changes were needed."
else
  echo ".gitignore updated with Phase 487 volatile docs runtime output ignores."
fi

rm -f "$TMP_FILE"
