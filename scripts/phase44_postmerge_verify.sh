#!/usr/bin/env bash
set -euo pipefail
setopt NO_BANG_HIST 2>/dev/null || true
setopt NONOMATCH 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

echo "=== branch + HEAD ==="
git status -sb
git rev-parse --short HEAD

echo
echo "=== Phase 44 smoke ==="
./scripts/phase44_action_tier_guard_smoke.sh

echo
echo "=== ensure CI workflow exists ==="
ls -la .github/workflows | rg -n "ci-build-and-test\.yml|ci_build_and_test_status_context\.yml|ci\.yml" || true

echo
echo "=== verify guard wiring present ==="
rg -n "assertActionTierInvariant|RUNTIME_INTEGRITY_GUARD|phase44_runtime_integrity_guard" server/api/tasks-mutations/delegate-taskspec.mjs server/guards/phase44_runtime_integrity_guard.mjs

echo
echo "=== show Phase 44 files ==="
ls -la server/guards/ scripts/ | rg -n "phase44|PHASE44\.md"
