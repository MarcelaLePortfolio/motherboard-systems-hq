#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX GOVERNED REMOTE PUSH URL MISMATCH SMOKE ==="
echo "MODE=EXECUTION"
echo "HYPOTHESIS=REMOTE_PUSH_EFFECT_IMPLEMENTATION_REMAINS_VALID"
echo "FAILURE_CLASS=TEST_FIXTURE_USED_NONEXISTENT_EXPECTED_REMOTE_PATH"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="1c7a5d6b7"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path

path = Path("server/execution/smoke-test-governed-remote-push.ts")
text = path.read_text()

old = '''{
  const fixture = createFixture();

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        expectedRemoteUrl:
          path.join(
            fixture.root,
            "wrong.git",
          ),
      }),
    /remote URL/,
  );
}
'''

new = '''{
  const fixture = createFixture();

  const wrongBare =
    path.join(
      fixture.root,
      "wrong.git",
    );

  git(fixture.root, [
    "init",
    "--bare",
    wrongBare,
  ]);

  assert.throws(
    () =>
      performGovernedRemotePush({
        ...baseInput(fixture),
        expectedRemoteUrl:
          wrongBare,
      }),
    /remote URL/,
  );
}
'''

if old not in text:
    raise SystemExit("STOP: expected remote URL mismatch smoke block not found")

path.write_text(text.replace(old, new, 1))
PY

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit
echo "TSC=PASS"

echo
echo "=== TEMP BARE REMOTE PUSH SMOKE ==="
npx tsx server/execution/smoke-test-governed-remote-push.ts
echo "REMOTE_PUSH_SMOKE=PASS"

echo
echo "=== VERIFY GENERIC ROUTES UNCHANGED ==="
if git diff -- \
  server/cade/cade-executor.ts \
  routes/cade.ts \
  server/routes/cade.ts \
  server/execution/execution-approval-gate.mjs \
  server/execution/governance-validator.mjs \
  server/execution/matilda-execution-switch-evaluator.ts \
  server/execution/cade-governed-commit-adapter.ts \
  | grep -q .; then
  echo "STOP: prohibited authority surface changed"
  exit 1
fi
echo "PROTECTED_SURFACES_UNCHANGED=YES"

echo
echo "=== VERIFY PUSH PROCESS SHAPE ==="
node - <<'NODE'
const fs = require("fs");
const assert = require("node:assert/strict");

const source = fs.readFileSync(
  "server/cade/cade-version-control-effects.ts",
  "utf8",
);

assert.match(source, /execFileSync/);
assert.match(source, /shell:\s*false/);
assert.match(source, /"push"/);
assert.match(source, /HEAD:refs\/heads\//);

assert.doesNotMatch(source, /--force/);
assert.doesNotMatch(source, /--force-with-lease/);

console.log("REMOTE_PUSH_PROCESS_BOUNDARY=PASS");
NODE

AUTHORIZED_FILES=(
  server/cade/cade-version-control-effects.ts
  server/execution/cade-governed-push-adapter.ts
  server/execution/smoke-test-governed-remote-push.ts
)

if [[ -n "$(git diff --cached --name-only)" ]]; then
  echo "STOP: pre-existing staged files detected"
  git diff --cached --name-only
  exit 1
fi

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
  echo "STOP: staged set exceeds authorized remote push unit"
  git restore --staged -- "${AUTHORIZED_FILES[@]}"
  exit 1
fi

git commit -m "Add governed Cade remote push effect"
git push

echo
echo "GOVERNED_REMOTE_PUSH_EFFECT_UNIT=COMMITTED_AND_PUSHED"
echo "ACTIVE_PROJECT_REMOTE_PUSH_EXECUTION=NOT_ENABLED"
echo "GENERIC_CADE_ROUTE_REACHABILITY=NO"
echo "NEXT_ACTION=VALIDATE_AND_CLOSE_REMOTE_PUSH_EFFECT_UNIT_BEFORE_ANY_PRODUCTION_REACHABILITY"
