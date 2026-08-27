#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX GOVERNED LOCAL COMMIT REPO ROOT CANONICALIZATION ==="
echo "MODE=EXECUTION"
echo "HYPOTHESIS=LOCAL_COMMIT_EFFECT_IMPLEMENTATION_REMAINS_VALID"
echo "FAILURE_CLASS=MACOS_TEMP_PATH_CANONICALIZATION_MISMATCH"
echo "REMOTE_PUSH_EFFECT=NO"
echo "GENERIC_CADE_EXECUTOR_CHANGE=NO"

EXPECTED_HEAD_PREFIX="00e9c064c"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("server/cade/cade-version-control-effects.ts")
text = path.read_text()

old_import = '''import path from "node:path";
import { execFileSync } from "node:child_process";
'''

new_import = '''import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
'''

old_normalize = '''function normalizeRepoPath(repoPath: string): string {
  return path.resolve(repoPath);
}
'''

new_normalize = '''function normalizeRepoPath(repoPath: string): string {
  const resolved = path.resolve(repoPath);

  try {
    return fs.realpathSync.native(resolved);
  } catch {
    return fs.realpathSync(resolved);
  }
}
'''

if old_import not in text:
    raise SystemExit("STOP: expected import anchor not found")

if old_normalize not in text:
    raise SystemExit("STOP: expected normalizeRepoPath anchor not found")

text = text.replace(old_import, new_import, 1)
text = text.replace(old_normalize, new_normalize, 1)

path.write_text(text)
PY

echo
echo "=== VERIFY CANONICALIZATION PATCH ONLY ==="
git diff -- server/cade/cade-version-control-effects.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== TEMP-REPOSITORY GOVERNED LOCAL COMMIT SMOKE ==="
npx tsx server/execution/smoke-test-governed-local-commit.ts
echo "LOCAL_COMMIT_SMOKE=PASS"

echo
echo "=== VERIFY GENERIC EXECUTION SURFACES UNCHANGED ==="
if git diff -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  | grep -q .; then
  echo "STOP: prohibited authority surface changed"
  exit 1
fi

echo "GENERIC_EXECUTION_SURFACES_UNCHANGED=YES"

echo
echo "=== VERIFY PROCESS BOUNDARY ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(source, /execFileSync/);
assert.match(source, /shell:\s*false/);
assert.match(source, /realpathSync/);

assert.doesNotMatch(
  source,
  /\bexecSync\s*\(/,
);

assert.doesNotMatch(
  source,
  /\bspawn\s*\(/,
);

assert.doesNotMatch(
  source,
  /["']push["']/,
);

assert.doesNotMatch(
  source,
  /--force/,
);

console.log("PROCESS_BOUNDARY=PASS");
NODE

echo
echo "=== VERIFY AUTHORIZED PATCH SET ==="
AUTHORIZED_FILES=(
  server/cade/cade-version-control-effects.ts
  server/execution/cade-governed-commit-adapter.ts
  server/execution/smoke-test-governed-local-commit.ts
)

if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

for f in "${AUTHORIZED_FILES[@]}"; do
  if [[ ! -f "${f}" ]]; then
    echo "STOP: authorized file missing: ${f}"
    exit 1
  fi
done

git add "${AUTHORIZED_FILES[@]}"

EXPECTED="$(
  printf '%s\n' "${AUTHORIZED_FILES[@]}" | sort
)"

ACTUAL="$(
  git diff --cached --name-only | sort
)"

echo "STAGED_FILES:"
printf '%s\n' "${ACTUAL}"

if [[ "${ACTUAL}" != "${EXPECTED}" ]]; then
  echo "STOP: staged set exceeds authorized local commit unit"
  git reset
  exit 1
fi

git commit -m "Add governed Cade local commit effect"
git push

echo
echo "GOVERNED_LOCAL_COMMIT_EFFECT_UNIT=COMMITTED_AND_PUSHED"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "REMOTE_PUSH_EFFECT=NOT_ENABLED"
echo "NEXT_ACTION=VALIDATE_LOCAL_COMMIT_EFFECT_CLOSURE_BEFORE_CLASSIFYING_PUSH_SUCCESSOR"
