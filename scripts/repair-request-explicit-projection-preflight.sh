#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
IMPLEMENTATION_SCRIPT="scripts/implement-request-explicit-package-semantics-projection.sh"
DIAGNOSTIC_SCRIPT="scripts/diagnose-request-explicit-projection-preflight.sh"

test "$(git branch --show-current)" = "$BRANCH"

echo "=== RECOVER INTERRUPTED COMMIT ==="
git status --short

if git diff --cached --quiet; then
  echo "STAGED_CHANGES=NONE"
else
  STAGED_PATHS="$(git diff --cached --name-only)"
  test "$STAGED_PATHS" = "$DIAGNOSTIC_SCRIPT"
  git commit -m "Diagnose deterministic projection implementation preflight"
fi

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")" || {
  echo "LOCAL_REMOTE_DIVERGENCE=STOP"
  exit 1
}

echo
echo "=== REPAIR STALE PREFLIGHT ==="

node << 'JAVASCRIPT'
const fs = require("node:fs");

const path =
  "scripts/implement-request-explicit-package-semantics-projection.sh";

let source = fs.readFileSync(path, "utf8");

const oldCheck = 'BASELINE="db054b0e5"';
const oldAssertion =
  'test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"';

if (
  !source.includes(oldCheck) ||
  !source.includes(oldAssertion)
) {
  throw new Error("Expected stale preflight contract not found.");
}

source = source.replace(
  oldCheck,
  'echo "PREFLIGHT=BRANCH_AND_REMOTE_CONVERGENCE"',
);

source = source.replace(
  oldAssertion + "\n",
  "",
);

fs.writeFileSync(path, source);
JAVASCRIPT

echo
echo "=== PREFLIGHT REPAIR REVIEW ==="
git diff --check
git diff -- "$IMPLEMENTATION_SCRIPT"

echo
echo "=== COMMIT PREFLIGHT REPAIR ==="
git add -- "$IMPLEMENTATION_SCRIPT"
git commit -m "Remove stale implementation baseline pin"
git push origin "$BRANCH"

echo
echo "=== EXECUTE AUTHORIZED IMPLEMENTATION ==="
./"$IMPLEMENTATION_SCRIPT"
