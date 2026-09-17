#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="4df267cf1"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

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

git commit -m "Add Atlas read-only pre-execution presentation"
git push origin "$BRANCH"

printf '\n===== POST-IMPLEMENTATION COMMIT =====\n'
printf 'HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'UPSTREAM=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
echo "IMPLEMENTATION_PUSH=VERIFIED"
