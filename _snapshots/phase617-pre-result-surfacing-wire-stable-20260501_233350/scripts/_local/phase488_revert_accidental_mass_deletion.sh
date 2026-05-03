#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "===== PHASE 488 — REVERT ACCIDENTAL MASS DELETION ====="
echo
echo "[1] VERIFY HEAD"
git log --oneline -n 5
echo

echo "[2] REVERT fb6695ce"
git revert --no-edit fb6695ce

echo
echo "[3] STATUS AFTER REVERT"
git status --short
echo

echo "[4] PUSH REVERT"
git push origin HEAD

echo
echo "[5] POST-REVERT HEAD"
git log --oneline -n 5
