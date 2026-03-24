#!/usr/bin/env bash

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

TAG="v151p-registry-live-wiring-governed-metadata-golden"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

echo "Phase 151P — Registry Golden Tag + Protection Seal"
echo "=================================================="
echo

echo "[1/4] Running registry verification"
./scripts/operator/registry_verify.sh
echo

echo "[2/4] Creating golden tag"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 151P golden checkpoint"
  echo "Created local tag: $TAG"
fi
echo

echo "[3/4] Pushing golden tag"
git push origin "$TAG"
echo

echo "[4/4] Seal complete"
echo "Golden checkpoint established: $TAG"
