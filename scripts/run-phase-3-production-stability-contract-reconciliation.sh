#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN PHASE 3 CORRIDOR 1 RECONCILIATION ==="
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "SUBJECT=$(git log -1 --pretty=%s)"
echo "BRANCH=$(git branch --show-current)"

test "$(git rev-parse --short=8 HEAD)" = "c8099e5b"
test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"

./scripts/reconcile-phase-3-production-stability-contract.sh
