#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
WORKFLOW="server/matilda-chat-workflow.ts"
MODULE="server/matilda-request-explicit-package-semantics.ts"
TEST="server/matilda-request-explicit-package-semantics.test.ts"

test "$(git branch --show-current)" = "$BRANCH"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== VERIFY EXACT ROLLBACK SCOPE ==="

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

if (current.split(importLine).length !== 2) {
  throw new Error("STOP: Unexpected projection import structure.");
}

if (current.split(projectionBlock).length !== 2) {
  throw new Error("STOP: Unexpected projection block structure.");
}

const restored = current
  .replace(importLine, "")
  .replace(projectionBlock, "")
  .replaceAll(
    "reconciledPackageSemantics,",
    "ollamaResult.packageSemantics,",
  );

if (restored !== baseline) {
  throw new Error("STOP: Workflow contains changes outside the reviewed projection.");
}

console.log("EXACT_ROLLBACK_SCOPE=VERIFIED");
JAVASCRIPT

echo
echo "=== PRESERVE REVIEW COPY ==="

BACKUP="$(mktemp -d "${TMPDIR:-/tmp}/matilda-projection-rollback.XXXXXX")"
cp "$WORKFLOW" "$MODULE" "$TEST" "$BACKUP/"
echo "REVIEW_BACKUP=$BACKUP"

echo
echo "=== RESTORE ONLY VERIFIED FILES ==="

git restore --source=HEAD --worktree -- "$WORKFLOW"
rm -- "$MODULE" "$TEST"

echo
echo "=== VERIFY RESTORED BASELINE ==="

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
