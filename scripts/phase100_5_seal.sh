#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 100.5 seal verification starting..."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing seal verification: working tree is not clean."
  git status --short
  exit 1
fi

REQUIRED_FILES=(
  "src/cognition/contracts/cognition.contracts.ts"
  "src/cognition/contracts/index.ts"
  "src/cognition/invariants/cognition.invariants.ts"
  "src/cognition/invariants/index.ts"
  "src/cognition/drift/cognition.drift.guard.ts"
  "src/cognition/drift/index.ts"
  "src/cognition/replay/cognition.replay.proof.ts"
  "src/cognition/replay/index.ts"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Phase 100 file: $file"
    exit 1
  fi
done

echo "Required Phase 100 cognition files present."

git rev-parse --verify HEAD >/dev/null 2>&1

echo "Latest commit:"
git log -1 --oneline

echo "Phase 100.5 seal verification PASS."
echo "Phase 100 cognition hardening is structurally complete and ready for operator-directed seal."
