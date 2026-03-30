#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v364-governance-operator-dictionary-foundation-golden"

bash scripts/_local/phase364_verify_governance_operator_dictionary.sh

git tag -a "$TAG" -m "Phase 364 governance operator dictionary foundation golden"
git push origin "$TAG"

echo "PASS: Phase 364 sealed"
