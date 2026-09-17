#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="4df267cf1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

git add \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

printf '\n===== STAGED FILES =====\n'
git diff --cached --name-status

printf '\n===== EXACT STAGED SCOPE CHECK =====\n'
EXPECTED="$(
  printf '%s\n' \
    client/src/atlas/AtlasPreexecutionPresentation.tsx \
    client/src/atlas/atlasPreexecutionApi.ts \
    client/src/shell/Shell.tsx \
    client/src/shell/shell.css |
  sort
)"

ACTUAL="$(git diff --cached --name-only | sort)"

if test "$ACTUAL" != "$EXPECTED"; then
  echo "STAGED_SCOPE=FAILED"
  printf '\nEXPECTED:\n%s\n' "$EXPECTED"
  printf '\nACTUAL:\n%s\n' "$ACTUAL"
  exit 1
fi
echo "STAGED_SCOPE=PASSED"

printf '\n===== COMPLETE STAGED DIFF =====\n'
git diff --cached -- \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

printf '\n===== READ-ONLY BOUNDARY =====\n'
if grep -RniE \
  'method:[[:space:]]*"(POST|PUT|PATCH|DELETE)"|createMatildaConversation|setActiveMatildaConversation|sendMatildaMessage' \
  client/src/atlas
then
  echo "READ_ONLY_BOUNDARY=FAILED"
  exit 1
fi
echo "READ_ONLY_BOUNDARY=PASSED"

printf '\n===== TYPESCRIPT TARGET DIAGNOSTIC =====\n'
DIAGNOSTIC="$(cd client && npx tsc --noEmit --pretty false 2>&1 || true)"
ATLAS_SHELL_ERRORS="$(
  printf '%s\n' "$DIAGNOSTIC" |
  grep -E 'src/atlas/|src/shell/Shell\.tsx' || true
)"

if test -n "$ATLAS_SHELL_ERRORS"; then
  echo "ATLAS_SHELL_TYPESCRIPT=FAILED"
  printf '%s\n' "$ATLAS_SHELL_ERRORS"
  exit 1
fi
echo "ATLAS_SHELL_TYPESCRIPT=PASSED"

printf '\n===== KNOWN EXTERNAL BLOCKER =====\n'
printf '%s\n' "$DIAGNOSTIC" |
  grep -E 'src/approvals/ApprovalsWorkspace\.tsx.*TS6133' || true

git commit -m "Add Atlas read-only pre-execution presentation"
git push origin "$BRANCH"
