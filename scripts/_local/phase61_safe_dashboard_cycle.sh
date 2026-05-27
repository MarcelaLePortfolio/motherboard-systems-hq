#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="${1:-public/dashboard.html}"

echo "==> Phase 61 safe dashboard cycle"
echo "==> root: $ROOT_DIR"
echo "==> target: $TARGET_HTML"

if [[ ! -f "$TARGET_HTML" ]]; then
  echo "ERROR: target HTML not found: $TARGET_HTML" >&2
  exit 1
fi

if [[ ! -x scripts/verify-dashboard-layout-contract.sh ]]; then
  echo "ERROR: verifier missing or not executable: scripts/verify-dashboard-layout-contract.sh" >&2
  exit 1
fi

echo "==> running layout contract verifier"
scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

echo "==> building dashboard container"
docker compose build dashboard

echo "==> restarting dashboard container"
docker compose up -d dashboard

echo "==> verifying locked checkpoint consistency"
if [[ -x scripts/_local/verify_phase61_layout_contract_locked_checkpoint.sh ]]; then
  scripts/_local/verify_phase61_layout_contract_locked_checkpoint.sh
else
  echo "WARN: checkpoint verifier not executable; skipping runtime consistency verification"
fi

echo "==> Phase 61 safe cycle complete"
