#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v353-governance-operator-ledger-foundation-golden"

echo "== Phase 353 seal =="

if [[ -n "$(git status --porcelain)" ]]; then
echo "Working tree dirty"
exit 1
fi

bash scripts/_local/phase353_verify_governance_operator_ledger.sh

if git rev-parse "$TAG" >/dev/null 2>&1; then
echo "Tag exists"
else
git tag -a "$TAG" -m "Phase 353 ledger foundation"
fi

git push origin "$TAG"

echo "PASS: Phase 353 sealed"
