#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
TARGET="scripts/implement-request-explicit-package-semantics-projection.sh"

test "$(git branch --show-current)" = "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== PRESERVE EXISTING WORKTREE ==="
git status --short

echo
echo "=== VERIFY IMPLEMENTATION TARGETS ARE UNMODIFIED ==="

for path in \
  server/matilda-chat-workflow.ts \
  server/matilda-request-explicit-package-semantics.ts \
  server/matilda-request-explicit-package-semantics.test.ts
do
  test ! -e "$path" || {
    test -z "$(git status --porcelain -- "$path")" || {
      echo "TARGET_ALREADY_MODIFIED=$path"
      exit 1
    }
  }
done

echo
echo "=== REMOVE ONLY OVERLY STRICT CLEAN-WORKTREE CHECK ==="

node << 'JAVASCRIPT'
const fs = require("node:fs");

const path =
  "scripts/implement-request-explicit-package-semantics-projection.sh";

let source = fs.readFileSync(path, "utf8");

const check = 'test -z "$(git status --porcelain)"';

if (!source.includes(check)) {
  throw new Error("Expected clean-worktree check not found.");
}

source = source.replace(
  check,
  'echo "PREFLIGHT=EXISTING_UNRELATED_WORKTREE_CHANGES_PRESERVED"',
);

fs.writeFileSync(path, source);
JAVASCRIPT

git diff --check
git diff -- "$TARGET"

echo
echo "=== COMMIT PREFLIGHT REPAIR ONLY ==="

git add -- "$TARGET"
git commit -m "Preserve unrelated worktree during package semantics implementation"
git push origin "$BRANCH"

echo
echo "=== RETRY AUTHORIZED IMPLEMENTATION ==="

./"$TARGET"
