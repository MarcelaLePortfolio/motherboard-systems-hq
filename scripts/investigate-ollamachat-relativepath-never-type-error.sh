#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE OLLAMACHAT RELATIVEPATH NEVER TYPE ERROR ==="

echo
echo "=== BASELINE ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
git status --short

echo
echo "=== EXACT FAILURE REGION ==="
nl -ba scripts/utils/ollamaChat.ts | sed -n '1080,1165p'

echo
echo "=== RELEVANT DEFINITIONS ==="
grep -nE \
  'relativePath|lineNumber|selectedContext|supportSource|sourceReference|reference|candidate' \
  scripts/utils/ollamaChat.ts |
head -n 320 || true

echo
echo "=== REPRODUCE TYPESCRIPT FAILURE ==="
set +e
npm run check > /tmp/matilda-ts-check.log 2>&1
CHECK_STATUS=$?
set -e

cat /tmp/matilda-ts-check.log

echo
echo "TSC_EXIT_STATUS=$CHECK_STATUS"

echo
echo "=== CLASSIFY TARGET ERROR ==="
grep -nE \
  "ollamaChat\.ts\(1130,(26|52)\).*TS2339.*(relativePath|lineNumber).*never" \
  /tmp/matilda-ts-check.log || true

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts; then
  echo "STOP: ollamaChat.ts changed during investigation."
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "LOCAL_RUNTIME_START_FAILURE=CONFIRMED"
echo "FAILURE_CLASS=TYPESCRIPT_COMPILE_ERROR"
echo "FAILURE_FILE=scripts/utils/ollamaChat.ts"
echo "FAILURE_LINE=1130"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_SMALLEST_SAFE_TYPE_FIX"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-ollamachat-relativepath-never-type-error.sh
git diff --cached --check
git commit -m "Investigate Ollama Chat never type error"
git push
