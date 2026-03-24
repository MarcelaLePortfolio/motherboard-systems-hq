#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

scripts/_local/phase128_run_consumption_registry_enforcement.sh

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing to seal: working tree is not clean."
  git status --short
  exit 1
fi

TAG="v128.0-consumption-registry-enforcement-golden"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag already exists locally: $TAG"
else
  git tag -a "$TAG" -m "Phase 128 golden checkpoint"
  echo "Created local tag: $TAG"
fi

git push origin "$TAG"

echo "phase128 seal: PASS"
