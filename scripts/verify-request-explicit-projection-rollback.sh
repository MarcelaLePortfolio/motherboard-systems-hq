#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="9ef3862a8"
WORKFLOW="server/matilda-chat-workflow.ts"
MODULE="server/matilda-request-explicit-package-semantics.ts"
TEST="server/matilda-request-explicit-package-semantics.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFY ROLLBACK SCOPE ==="

test -f "$WORKFLOW"
test -f "$MODULE"
test -f "$TEST"

test -z "$(git ls-files -- "$MODULE" "$TEST")"

node << 'JAVASCRIPT'
const fs = require("node:fs");
const cp = require("node:child_process");

const file = "server/matilda-chat-workflow.ts";
const current = fs.readFileSync(file, "utf8");
const baseline = cp.execFileSync(
  "git",
  ["show", `HEAD:${file}`],
  { encoding: "utf8" },
);

const importLine =
  'import { projectRequestExplicitPackageSemantics } from "./matilda-request-explicit-package-semantics";\n';

const projectionBlock = `    const reconciledPackageSemantics =
      projectRequestExplicitPackageSemantics(
        message,
        ollamaResult.packageSemantics,
        input.userPackageSemantics,
      );

`;

if (!current.includes(importLine) || !current.includes(projectionBlock)) {
  throw new Error("STOP: Expected implementation structure differs.");
}

const restored = current
  .replace(importLine, "")
  .replace(projectionBlock, "")
  .replaceAll(
    "reconciledPackageSemantics,",
    "ollamaResult.packageSemantics,",
  );

if (restored !== baseline) {
  throw new Error(
    "STOP: Workflow contains changes outside the reviewed projection.",
  );
}

console.log("ROLLBACK_SCOPE_VERIFIED=YES");
console.log("UNRELATED_WORKFLOW_CHANGES=NONE");
JAVASCRIPT

echo
echo "=== PRESERVE ABANDONED IMPLEMENTATION ==="

BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/matilda-projection-rollback.XXXXXX")"

cp "$WORKFLOW" "$MODULE" "$TEST" "$BACKUP/"

echo "REVIEW_BACKUP=$BACKUP"

echo
echo "=== RESTORE EXACT BASELINE ==="

git restore --source=HEAD --worktree -- "$WORKFLOW"
rm -- "$MODULE" "$TEST"

echo
echo "=== VERIFY ==="

git diff --exit-code HEAD -- "$WORKFLOW"

test ! -e "$MODULE"
test ! -e "$TEST"

npx tsc --noEmit
git diff --check

echo
echo "ROLLBACK=COMPLETE"
echo "TYPECHECK=PASS"
echo "UNRELATED_WORKTREE_CHANGES=PRESERVED"
echo "FUNCTIONAL_SOURCE_COMMIT=NONE"
echo "DOGFOOD=NONE"
echo "NEXT_ACTION=REASSESS_UPSTREAM_VALIDATION_SEAM"
