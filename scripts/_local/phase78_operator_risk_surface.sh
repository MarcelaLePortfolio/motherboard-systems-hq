#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "PHASE 78 — OPERATOR RISK SURFACE"
echo "--------------------------------"

echo "RISK CHECK — SAFETY GATE"
bash scripts/_local/phase73_run_safety_gate.sh || true

echo ""
echo "RISK CHECK — WORKTREE DIRTINESS"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "risk=worktree_dirty"
else
  echo "risk=worktree_clean"
fi

echo ""
echo "RISK CHECK — UNPUSHED COMMITS"
AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
if [[ "$AHEAD" -gt 0 ]]; then
  echo "risk=unpushed_commits count=$AHEAD"
else
  echo "risk=fully_pushed"
fi

echo ""
echo "RISK CHECK — CONTAINER STATE"
if docker compose ps 2>/dev/null | grep -q Exit; then
  echo "risk=container_exit_detected"
else
  echo "risk=containers_healthy"
fi

echo ""
echo "RISK SURFACE RESULT: REVIEW COMPLETE"
