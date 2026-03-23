#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 101.4 seal verification starting..."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing seal verification: working tree is not clean."
  git status --short
  exit 1
fi

REQUIRED_FILES=(
  "src/cognition/exposure/cognition.exposure.ts"
  "src/cognition/exposure/index.ts"
  "src/cognition/selectors/cognition.selectors.ts"
  "src/cognition/selectors/index.ts"
  "src/cognition/operator-read/cognition.operator-read.ts"
  "src/cognition/operator-read/index.ts"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Phase 101 file: $file"
    exit 1
  fi
done

echo "Required Phase 101 cognition exposure files present."

git rev-parse --verify HEAD >/dev/null 2>&1

echo "Latest commit:"
git log -1 --oneline

echo "Phase 101.4 seal verification PASS."
echo "Phase 101 cognition exposure is structurally complete and ready for operator-directed seal."
