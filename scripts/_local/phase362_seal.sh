#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v362-governance-operator-glossary-foundation-golden"

bash scripts/_local/phase362_verify_governance_operator_glossary.sh

git tag -a "$TAG" -m "Phase 362 governance operator glossary foundation golden"
git push origin "$TAG"

echo "PASS: Phase 362 sealed"
