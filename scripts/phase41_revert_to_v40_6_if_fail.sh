#!/usr/bin/env bash
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1

if ! scripts/phase41_invariants_gate.sh; then
  git reset --hard
  git clean -fd
  git checkout -f "v40.6-shadow-audit-task-events-green"
  echo "Reverted to v40.6-shadow-audit-task-events-green"
  exit 1
fi

echo "OK: no revert needed."
