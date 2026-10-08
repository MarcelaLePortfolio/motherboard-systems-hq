#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFY CORRECTED RECONCILIATION INPUT ==="

node << 'JAVASCRIPT'
const fs = require("node:fs");

const source = fs.readFileSync(
  "server/matilda-chat-workflow.ts",
  "utf8",
);

const expected = `const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        ollamaResult.packageSemantics,
        input.userPackageSemantics,
      );`;

if (!source.includes(expected)) {
  throw new Error("Expected corrected reconciliation block absent.");
}

console.log("RECONCILIATION_SELF_REFERENCE=ABSENT");
JAVASCRIPT

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== TARGETED TESTS ==="
node --test --experimental-strip-types \
  server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== DIFF INTEGRITY ==="
git diff --check

echo
echo "=== FUNCTIONAL CHANGE REVIEW ==="
git diff -- server/matilda-chat-workflow.ts
git status --short -- \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== VALIDATION RESULT ==="
echo "SOURCE_MUTATION_PERFORMED=NO"
echo "FUNCTIONAL_COMMIT_PERFORMED=NO"
echo "DOGFOOD_PERFORMED=NO"
echo "NEXT_ACTION=REVIEW_VALIDATION_AND_REMAINING_AUTHORITY_BOUNDARIES"
