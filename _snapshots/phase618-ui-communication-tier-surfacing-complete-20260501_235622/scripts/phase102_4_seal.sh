#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "Phase 102.4 seal verification starting..."

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Refusing seal verification: working tree is not clean."
  git status --short
  exit 1
fi

REQUIRED_FILES=(
  "src/cognition/gateway/cognition.gateway.ts"
  "src/cognition/gateway/index.ts"
  "src/cognition/guard/cognition.guard.ts"
  "src/cognition/guard/index.ts"
  "src/cognition/adapter/cognition.adapter.ts"
  "src/cognition/adapter/index.ts"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required Phase 102 file: $file"
    exit 1
  fi
done

echo "Required Phase 102 cognition consumption files present."

git rev-parse --verify HEAD >/dev/null 2>&1

echo "Latest commit:"
git log -1 --oneline

echo "Phase 102.4 seal verification PASS."
echo "Phase 102 cognition consumption is structurally complete and ready for operator-directed seal."
