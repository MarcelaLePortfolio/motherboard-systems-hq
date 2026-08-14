#!/usr/bin/env bash
set -euo pipefail

echo "=== REPAIR TARGETED PROMPT DIAGNOSTIC VALIDATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor e2cd70c3 HEAD

runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"
validation="scripts/targeted-validate-prompt-diagnostic-surfaces.sh"

test -f "$runner"
test -f "$validation"

python3 <<'PY'
from pathlib import Path

path = Path("scripts/run-bounded-prompt-presentation-diagnostic.ts")
text = path.read_text()

old = """const observations: Observation[] = [];

for (let pair = 1; pair <= PAIR_COUNT; pair += 1) {
  observations.push(await run(pair, "control"));
  observations.push(await run(pair, "experimental"));
}

function summarize(arm: Arm) {
"""
new = """async function main(): Promise<void> {
  const observations: Observation[] = [];

  for (let pair = 1; pair <= PAIR_COUNT; pair += 1) {
    observations.push(await run(pair, "control"));
    observations.push(await run(pair, "experimental"));
  }

  function summarize(arm: Arm) {
"""
if old not in text:
    raise SystemExit("STOP: expected top-level await block not found.")
text = text.replace(old, new, 1)

old = """console.log("PRODUCTION_PROMPT_CHANGE=NONE");
console.log("PRODUCTION_GENERATION_POLICY_CHANGE=NONE");
console.log("VALIDATOR_CHANGE=NONE");
console.log("MODEL_CHANGE=NONE");
console.log("RETRY_OR_SECOND_MODEL_CALL=NONE");
console.log("PRODUCTION_CHANGE=NONE");
"""
new = """  console.log("PRODUCTION_PROMPT_CHANGE=NONE");
  console.log("PRODUCTION_GENERATION_POLICY_CHANGE=NONE");
  console.log("VALIDATOR_CHANGE=NONE");
  console.log("MODEL_CHANGE=NONE");
  console.log("RETRY_OR_SECOND_MODEL_CALL=NONE");
  console.log("PRODUCTION_CHANGE=NONE");
}

void main();
"""
if old not in text:
    raise SystemExit("STOP: expected runner footer not found.")
text = text.replace(old, new, 1)

path.write_text(text)
PY

echo "=== TARGETED TYPESCRIPT CHECK ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  scripts/utils/ollamaChat.ts \
  scripts/run-bounded-prompt-presentation-diagnostic.ts

echo "TARGETED_TYPESCRIPT_CHECK=PASS"

git diff --check

cat <<'MAP'
REPAIR_CLASS=
TARGETED_DIAGNOSTIC_RUNNER_MODULE_COMPATIBILITY

STOP_CAUSE=
TOP_LEVEL_AWAIT_IN_COMMONJS_CLASSIFIED_RUNNER

REPAIR=
WRAP_DIAGNOSTIC_EXECUTION_IN_ASYNC_MAIN

SEMANTIC_CONTRACT=
UNCHANGED

DIAGNOSTIC_DESIGN=
UNCHANGED

PRODUCTION_CHANGE=
NONE

ATLAS_CHANGE=
NONE

TARGETED_TYPESCRIPT_CHECK=
PASS

NEXT_ACTION=
COMMIT_VALIDATED_DIAGNOSTIC_SURFACES
MAP
