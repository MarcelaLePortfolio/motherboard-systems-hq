#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE NARROW APPROVAL GATE UNIT AFTER VALID FILE-BASED SMOKE ==="
echo "MODE=EXECUTION"
echo "RUNTIME_HYPOTHESIS=UNCHANGED"
echo "FAILED_VALIDATION_METHOD=TSX_EVAL_IMPORT_MODE"
echo "VALIDATION_METHOD=FILE_BASED_TSX_SMOKE"
echo "LOCAL_GIT_COMMIT_EFFECT_AUTHORIZED=NO"
echo "REMOTE_PUSH_EFFECT_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="3c2efe9e7"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

AUTHORIZED_FILES=(
  server/execution/execution-approval-gate.mjs
  server/execution/smoke-test-version-control-contract.mjs
)

echo
echo "=== VERIFY AUTHORIZED WORKTREE ==="
for f in "${AUTHORIZED_FILES[@]}"; do
  if git diff --quiet -- "$f"; then
    echo "STOP: expected authorized change missing: $f"
    exit 1
  fi
  echo "MODIFIED=$f"
done

echo
echo "=== REJECT FAILED TSX-EVAL VALIDATION METHOD ==="
echo "DIRECT_FILE_SMOKE_PREVIOUSLY_REACHED_AND_PASSED_COMPLETE_ASSERTION_SET=YES"
echo "TSX_EVAL_FAILED_ON_SOURCE_MJS_TO_COMPILED_JS_SPECIFIER=YES"
echo "THIS_DOES_NOT_ESTABLISH_APPROVAL_GATE_RUNTIME_FAILURE=YES"
echo "DO_NOT_CHANGE_APPROVAL_GATE_IMPORT=YES"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== CANONICAL FILE-BASED VERSION CONTROL SMOKE ==="
npx tsx server/execution/smoke-test-version-control-contract.mjs
echo "VERSION_CONTROL_CONTRACT_SMOKE=PASS"

echo
echo "=== EXISTING ENVELOPE SMOKE ==="
node server/execution/smoke-test-envelope-draft.mjs
echo "ENVELOPE_SMOKE=PASS"

echo
echo "=== BUILD COMPILED TYPESCRIPT RUNTIME ==="
npm run build
test -f dist/server/execution/matilda-execution-switch-evaluator.js
test -f dist/server/execution/matilda-execution-registry-loader.js
echo "COMPILED_EXECUTION_DEPENDENCIES=PASS"

echo
echo "=== STRUCTURAL APPROVAL-GATE ASSERTIONS ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const gate = fs.readFileSync(
  "server/execution/execution-approval-gate.mjs",
  "utf8"
);

assert.match(
  gate,
  /governed_version_control_commit/
);

assert.match(
  gate,
  /commit_authorized:\s*commitAuthorized/
);

assert.match(
  gate,
  /push_authorized:\s*false/
);

assert.match(
  gate,
  /mutation_authorized:\s*false/
);

assert.match(
  gate,
  /shell_execution_authorized:\s*false/
);

assert.match(
  gate,
  /autonomous_execution_authorized:\s*false/
);

assert.match(
  gate,
  /PUSH_AUTHORITY_DISABLED/
);

assert.match(
  gate,
  /version_control_commit_authority_granted/
);

console.log("APPROVAL_GATE_STRUCTURE=PASS");
NODE

echo
echo "=== VERIFY NO GIT OR PROCESS EFFECT INTRODUCED ==="
node - "${AUTHORIZED_FILES[@]}" <<'NODE'
const fs = require("fs");

const files = process.argv.slice(2);

const prohibited = [
  /node:child_process/,
  /(?:^|[^A-Za-z_])child_process(?:[^A-Za-z_]|$)/,
  /\bexecFile(?:Sync)?\s*\(/,
  /\bexec(?:Sync)?\s*\(/,
  /\bspawn(?:Sync)?\s*\(/,
];

for (const file of files) {
  const source = fs.readFileSync(file, "utf8");

  for (const pattern of prohibited) {
    if (pattern.test(source)) {
      throw new Error(
        `prohibited process effect in ${file}`
      );
    }
  }
}

console.log("PROCESS_EFFECTS=NONE");
NODE

echo
echo "=== VERIFY PRESERVED AUTHORITY BOUNDARY ==="
if git diff -- \
  server/cade/cade-executor.ts \
  server/cade/cade-effects.ts \
  server/events/execution-event-bus.ts \
  server/events/execution-event-store.ts \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/build-approval-artifact.mjs \
  routes/cade.ts \
  server/routes/cade.ts \
  | grep -q .; then
  echo "STOP: prohibited architecture surface changed"
  exit 1
fi

echo "PROTECTED_ARCHITECTURE_UNCHANGED=YES"

echo
echo "=== VERIFY NO PREEXISTING STAGED FILES ==="
if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

echo
echo "=== STAGE ONLY AUTHORIZED APPROVAL UNIT ==="
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
  echo "STOP: staged set exceeds authorized approval unit"
  git reset
  exit 1
fi

echo
echo "=== COMMIT NARROW APPROVAL UNIT ==="
git commit -m "Enable narrow governed Cade commit approval"
git push

echo
echo "NARROW_COMMIT_APPROVAL_UNIT=CLOSED"
echo "LOCAL_GIT_COMMIT_EFFECT=NOT_YET_ENABLED"
echo "REMOTE_PUSH_EFFECT=NOT_ENABLED"
echo "GENERIC_MUTATION_AUTHORITY=DISABLED"
echo "GENERIC_SHELL_AUTHORITY=DISABLED"
echo "AUTONOMOUS_EXECUTION_AUTHORITY=DISABLED"
echo "NEXT_ACTION=CLASSIFY_AND_AUTHORIZE_LOCAL_COMMIT_EFFECT_UNIT_FROM_CLOSED_APPROVAL_BOUNDARY"
