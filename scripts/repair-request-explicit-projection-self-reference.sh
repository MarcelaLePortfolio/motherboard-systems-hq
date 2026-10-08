#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"

test "$(git branch --show-current)" = "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFY EXACT FAILURE ==="

node << 'JAVASCRIPT'
const fs = require("node:fs");

const path = "server/matilda-chat-workflow.ts";
let source = fs.readFileSync(path, "utf8");

const incorrect = `    const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        reconciledPackageSemantics,
        input.userPackageSemantics,
      );`;

const corrected = `    const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        ollamaResult.packageSemantics,
        input.userPackageSemantics,
      );`;

if (!source.includes(incorrect)) {
  throw new Error(
    "Expected self-reference not found; stop without modifying source.",
  );
}

source = source.replace(incorrect, corrected);
fs.writeFileSync(path, source);
JAVASCRIPT

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== TARGETED TESTS ==="
node --test --experimental-strip-types \
  server/matilda-request-explicit-package-semantics.test.ts

echo
echo "=== REVIEW ==="
git diff --check
git diff -- "$WORKFLOW"

echo
echo "=== STATUS ==="
echo "IMPLEMENTATION_VALIDATION=COMPLETED"
echo "FUNCTIONAL_COMMIT_AUTHORIZED=NO"
echo "DOGFOOD_AUTHORIZED=NO"
echo "UNRELATED_WORKTREE_CHANGES_PRESERVED=YES"
