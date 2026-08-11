#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SOURCE-EXCERPT-FIRST FIXED-SEED SINGLE-RUN FAILURE ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-source-excerpt-fixed-seed-once.xue4be"
failure_signature='Ollama returned a conversation support reference that was not supplied in this invocation.'

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REQUIRED CHECKPOINT ==="
required_checkpoint="cefa8ef4"

if ! git merge-base --is-ancestor "$required_checkpoint" HEAD; then
  echo "STOP: required fixed-seed fixture checkpoint $required_checkpoint is not an ancestor of HEAD."
  exit 2
fi

echo "REQUIRED_FIXED_SEED_FIXTURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRESERVED FAILURE ARTIFACT ==="
stdout_file="$artifact_dir/source-excerpt.stdout.txt"
stderr_file="$artifact_dir/source-excerpt.stderr.txt"

for file in "$stdout_file" "$stderr_file"; do
  if [[ ! -f "$file" ]]; then
    echo "STOP: required preserved artifact missing: $file"
    exit 2
  fi
done

cat "$stdout_file"
cat "$stderr_file"

if ! grep -qF "$failure_signature" "$stderr_file"; then
  echo "STOP: expected conversation-support failure signature not found."
  exit 2
fi

echo "CONVERSATION_SUPPORT_FAILURE_SIGNATURE=CONFIRMED"

echo
echo "=== VERIFY FIXTURE REMAINS SEED-ONLY ADAPTATION ==="
python3 <<'PY'
from pathlib import Path

source = Path("scripts/validate-source-excerpt-first-live.ts").read_text()
adapted = Path("scripts/validate-source-excerpt-first-fixed-seed-live.ts").read_text()
seed_line = "      validationGenerationSeed: 424242,\n"

if adapted.count(seed_line) != 1:
    raise SystemExit("STOP: expected exactly one validation seed insertion")

if adapted.replace(seed_line, "", 1) != source:
    raise SystemExit("STOP: fixed-seed fixture differs beyond validation seed insertion")

print("SEED_ONLY_ADAPTATION=CONFIRMED")
PY

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=SOURCE_EXCERPT_FIRST_FIXED_SEED_SINGLE_RUN_FAILURE

OBSERVED_RESULT=
SOURCE_EXCERPT_FIRST_FIXED_SEED_DIAGNOSTIC_FAILED_CLOSED

FAILURE_SIGNATURE=
UNSUPPLIED_CONVERSATION_SUPPORT_REFERENCE

FAILURE_CLASS=
STRUCTURED_SEMANTIC_SUPPORT_IDENTITY_REJECTION

DETERMINISTIC_VALIDATOR=
PRESERVE

FAIL_CLOSED_BEHAVIOR=
PRESERVE

FIXTURE_ADAPTATION=
SEED_ONLY_DIFFERENCE_CONFIRMED

FIXED_SEED_SPECIFIC_REGRESSION=
NOT_ESTABLISHED

CLASSIFICATION=
The first compatible wider fixed-seed diagnostic reached the current
deterministic support-provenance validator and failed closed because the
generated response authored a conversation support reference that was not
supplied in the invocation.

This differs from the previously observed selected-context fixture failures
and from the earlier child-derived project-support identity failure.

The result does not establish that validationGenerationSeed=424242 caused
the failure. A direct run of the original unseeded source-excerpt-first
fixture under the same repository state is required before attributing this
failure to the fixed-seed candidate.

FIXTURE_REPAIR_AUTHORIZED=NO
SEED_CHANGE_AUTHORIZED=NO
PROMPT_CHANGE_AUTHORIZED=NO
VALIDATOR_RELAXATION_AUTHORIZED=NO
REPEATED_RUNS_AUTHORIZED=NO

SINGLE_UNSEEDED_BASELINE_COMPARISON=
AUTHORIZED

WIDER_SEMANTIC_PRESERVATION_STATUS=
BLOCKED_PENDING_SOURCE_EXCERPT_UNSEEDED_BASELINE_COMPARISON

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

NEXT_ACTION=
RUN_ORIGINAL_SOURCE_EXCERPT_FIRST_UNSEEDED_FIXTURE_ONCE_FOR_DIRECT_BASELINE_COMPARISON
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-source-excerpt-fixed-seed-single-run-failure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-source-excerpt-fixed-seed-single-run-failure.sh
git diff --cached --check
git commit -m "Classify source excerpt fixed seed single run failure"
git push
