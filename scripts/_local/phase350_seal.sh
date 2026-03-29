#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v350-governance-operator-manifest-index-foundation-golden"

echo "== Phase 350 seal =="

echo
echo "-- verifying working tree --"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

echo
echo "-- running Phase 350 verification --"
bash scripts/_local/phase350_verify_governance_operator_manifest_index.sh

echo
echo "-- creating tag if needed --"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 350 governance operator manifest index foundation golden checkpoint"
  echo "Created local tag: $TAG"
fi

echo
echo "-- pushing tag --"
git push origin "$TAG"

echo
echo "PASS: Phase 350 sealed at $TAG"
