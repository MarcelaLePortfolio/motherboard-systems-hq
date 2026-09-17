#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="2af069463"
IMPLEMENTATION_COMMIT="f64cb63e9"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n===== IMPLEMENTATION COMMIT =====\n'
git show --stat --oneline "$IMPLEMENTATION_COMMIT"

printf '\n===== RECORD COMMIT =====\n'
git show --stat --oneline "$EXPECTED_HEAD"

printf '\n===== TARGET FILES AT HEAD =====\n'
git ls-tree -r --name-only HEAD -- \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/atlas/atlasPreexecutionApi.ts \
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

printf '\n===== KNOWN EXTERNAL BUILD BLOCKER =====\n'
printf '%s\n' "$DIAGNOSTIC" |
  grep -E 'src/approvals/ApprovalsWorkspace\.tsx.*TS6133' || true

printf '\n===== VERDICT =====\n'
echo "ATLAS_MINIMUM_REACT_PRESENTATION=LANDED_AND_PUSHED"
echo "IMPLEMENTATION_COMMIT=$IMPLEMENTATION_COMMIT"
echo "ACTIVE_HEAD=$EXPECTED_HEAD"
