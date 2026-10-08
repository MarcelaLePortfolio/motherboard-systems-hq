#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-request-explicit-package-semantics.test.ts"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFY IMPLEMENTATION FILES ==="

test -f server/matilda-request-explicit-package-semantics.ts
test -f "$TEST"

node << 'JAVASCRIPT'
const fs = require("node:fs");

const workflow = fs.readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

const expected = `const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        ollamaResult.packageSemantics,
        input.userPackageSemantics,
      );`;

if (!workflow.includes(expected)) {
  throw new Error("Expected reconciliation block absent.");
}

console.log("RECONCILIATION_SELF_REFERENCE=ABSENT");
JAVASCRIPT

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== TARGETED TESTS WITH TYPESCRIPT MODULE RESOLUTION ==="

if [ -x node_modules/.bin/tsx ]; then
  node --import tsx --test "$TEST"
else
  echo "TSX_RUNNER_UNAVAILABLE=YES"
  echo "NO_DEPENDENCY_INSTALL_AUTHORIZED=YES"
  exit 1
fi

echo
echo "=== DIFF INTEGRITY ==="
git diff --check

echo
echo "=== FUNCTIONAL CHANGE REVIEW ==="
git diff -- server/matilda-chat-workflow.ts

echo
echo "=== IMPLEMENTATION STATUS ==="
git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  "$TEST"

echo "FUNCTIONAL_COMMIT_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=REVIEW_VALIDATION_AND_AUTHORITY_BOUNDARIES"
