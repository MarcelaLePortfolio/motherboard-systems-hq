#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 76 — OPERATOR START COMMAND"
echo "---------------------------------"
echo "generated_at=$(date +"%Y-%m-%d %H:%M:%S")"
echo "repo=$(basename "$ROOT_DIR")"
echo "branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
echo "commit=$(git rev-parse --short HEAD 2>/dev/null || echo unknown)"

echo ""
echo "STEP 1 — PREFLIGHT"
bash scripts/_local/phase75_operator_preflight.sh

echo ""
echo "STEP 2 — GUIDANCE STATUS"
bash scripts/_local/operator_guidance.sh status

echo ""
echo "STEP 3 — NEXT ACTION"
bash scripts/_local/operator_guidance_next_action.sh || true

echo ""
echo "STEP 4 — LAST CHECKPOINTS"
ls -1t docs/checkpoints | head -n 10 || true

echo ""
echo "STEP 5 — WORKTREE"
git status --short --branch

echo ""
echo "START COMMAND RESULT: OPERATOR READY"
