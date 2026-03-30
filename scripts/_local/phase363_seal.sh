#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v363-governance-operator-lexicon-foundation-golden"

bash scripts/_local/phase363_verify_governance_operator_lexicon.sh

git tag -a "$TAG" -m "Phase 363 governance operator lexicon foundation golden"
git push origin "$TAG"

echo "PASS: Phase 363 sealed"
