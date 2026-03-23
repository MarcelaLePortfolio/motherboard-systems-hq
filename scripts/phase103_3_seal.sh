#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 103.3 seal verification starting..."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing seal verification: working tree is not clean."
  git status --short
  exit 1
fi

REQUIRED_FILES=(
  "src/cognition/lock/cognition.lock.ts"
  "src/cognition/lock/index.ts"
  "src/cognition/invariants-read/cognition.read.invariants.ts"
  "src/cognition/invariants-read/index.ts"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Phase 103 file: $file"
    exit 1
  fi
done

echo "Required Phase 103 cognition stability files present."

git rev-parse --verify HEAD >/dev/null 2>&1

echo "Latest commit:"
git log -1 --oneline

echo "Phase 103.3 seal verification PASS."
echo "Phase 103 cognition stability is structurally complete."
