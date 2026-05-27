#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 80 — FINALIZE WORKSPACE CLEAN"
echo "-----------------------------------"

rm -rf artifacts/operational-closeout artifacts/operator-guidance

if [[ -e mount ]]; then
  rm -rf mount
fi

echo ""
echo "POST-CLEAN STATUS"
git status --short --branch
