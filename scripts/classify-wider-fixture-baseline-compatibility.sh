#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY WIDER FIXTURE BASELINE COMPATIBILITY ==="

unseeded_artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-wider-unseeded-baseline.xHN6iB"
seeded_artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-wider-fixed-seed-once.qVjjMM"
failure_signature='Ollama returned a selected context segment that was not supplied in this invocation.'

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REQUIRED CLASSIFICATION ANCESTOR ==="
required_checkpoint="d37c31f2"

if ! git merge-base --is-ancestor "$required_checkpoint" HEAD; then
  echo "STOP: required checkpoint $required_checkpoint is not an ancestor of HEAD."
  exit 2
fi

echo "REQUIRED_CLASSIFICATION_ANCESTOR_PRESENT=$required_checkpoint"

echo
echo "=== VERIFY PRESERVED COMPARISON ARTIFACTS ==="

for file in \
  "$seeded_artifact_dir/reasoning.stderr.txt" \
  "$seeded_artifact_dir/evidence.stderr.txt" \
  "$unseeded_artifact_dir/reasoning.stderr.txt" \
  "$unseeded_artifact_dir/evidence.stderr.txt"
do
  if [[ ! -f "$file" ]]; then
    echo "STOP: required artifact unavailable: $file"
    exit 2
  fi
done

echo "PRESERVED_COMPARISON_ARTIFACTS=CONFIRMED"

echo
echo "=== VERIFY SEEDED FAILURE SURFACE ==="

grep -qF "$failure_signature" "$seeded_artifact_dir/reasoning.stderr.txt" || {
  echo "STOP: seeded reasoning artifact does not match expected failure."
  exit 2
}

grep -qF "$failure_signature" "$seeded_artifact_dir/evidence.stderr.txt" || {
  echo "STOP: seeded evidence artifact does not match expected failure."
  exit 2
}

echo "SEEDED_REASONING_SELECTED_CONTEXT_FAILURE=YES"
echo "SEEDED_STRUCTURED_EVIDENCE_SELECTED_CONTEXT_FAILURE=YES"

echo
echo "=== VERIFY UNSEEDED FAILURE SURFACE ==="

grep -qF "$failure_signature" "$unseeded_artifact_dir/reasoning.stderr.txt" || {
  echo "STOP: unseeded reasoning artifact does not match expected failure."
  exit 2
}

grep -qF "$failure_signature" "$unseeded_artifact_dir/evidence.stderr.txt" || {
  echo "STOP: unseeded evidence artifact does not match expected failure."
  exit 2
}

echo "UNSEEDED_REASONING_SELECTED_CONTEXT_FAILURE=YES"
echo "UNSEEDED_STRUCTURED_EVIDENCE_SELECTED_CONTEXT_FAILURE=YES"

echo
echo "=== VERIFY ORIGINAL FIXTURE INPUT SHAPE ==="

for fixture in \
  scripts/validate-reasoning-composition-live.ts \
  scripts/validate-structured-evidence-object-live.ts
do
  echo "--- $fixture ---"
  grep -nE 'projectContextExcerpts|projectContextSegmentCandidates|validationGenerationSeed' "$fixture" || true

  if grep -q 'validationGenerationSeed' "$fixture"; then
    echo "STOP: original fixture unexpectedly contains validationGenerationSeed: $fixture"
    exit 2
  fi

  if ! grep -q 'projectContextExcerpts' "$fixture"; then
    echo "STOP: expected projectContextExcerpts input absent: $fixture"
    exit 2
  fi

  if grep -q 'projectContextSegmentCandidates' "$fixture"; then
    echo "STOP: fixture now supplies projectContextSegmentCandidates; reclassification required."
    exit 2
  fi
done

echo "ORIGINAL_FIXTURE_INPUT_SHAPE=CONFIRMED"

echo
echo "=== VERIFY CURRENT FAIL-CLOSED BOUNDARY ==="

grep -n -A25 -B8 \
  'selected context segment that was not supplied in this invocation' \
  scripts/utils/ollamaChat.ts

echo "CURRENT_SELECTED_CONTEXT_FAIL_CLOSED_BOUNDARY=CONFIRMED"

echo
echo "=== CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=WIDER_FIXTURE_BASELINE_COMPATIBILITY

SEEDED_REASONING_RESULT=
UNSUPPLIED_SELECTED_CONTEXT_FAILURE

UNSEEDED_REASONING_RESULT=
UNSUPPLIED_SELECTED_CONTEXT_FAILURE

SEEDED_STRUCTURED_EVIDENCE_RESULT=
UNSUPPLIED_SELECTED_CONTEXT_FAILURE

UNSEEDED_STRUCTURED_EVIDENCE_RESULT=
UNSUPPLIED_SELECTED_CONTEXT_FAILURE

SEEDED_VS_UNSEEDED_FAILURE_SURFACE=
MATCHES

FIXED_SEED_SPECIFIC_REGRESSION=
NOT_ESTABLISHED

FIXED_SEED_CANDIDATE_STATUS=
NOT_DISQUALIFIED_BY_THIS_COMPARISON

CLASSIFICATION=
The two wider fixed-seed fixtures fail on the same deterministic selected-
context validation boundary as their original unseeded counterparts.

Therefore the observed wider failures cannot presently be attributed to the
fixed validation seed.

The original fixtures supply projectContextExcerpts but do not supply
projectContextSegmentCandidates. They are therefore not currently admissible
as direct fixed-seed semantic-preservation comparisons when the generated
response selects project context and the runtime correctly validates that
selection against supplied candidate identities.

DETERMINISTIC_VALIDATOR=
PRESERVE

FAIL_CLOSED_BEHAVIOR=
PRESERVE

RUNTIME_REGRESSION=
NOT_ESTABLISHED

FIXTURE_REPAIR_AUTHORIZED=
NO

SEED_CHANGE_AUTHORIZED=
NO

VALIDATOR_RELAXATION_AUTHORIZED=
NO

REPEATED_WIDER_RUNS_AUTHORIZED=
NO

WIDER_SEMANTIC_PRESERVATION_STATUS=
BLOCKED_PENDING_COMPATIBLE_FIXTURE_CLASSIFICATION

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

NEXT_ACTION=
INVESTIGATE_CURRENT_REPOSITORY_SUPPORTED_WIDER_SEMANTIC_FIXTURES_COMPATIBLE_WITH_SELECTED_CONTEXT_VALIDATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-wider-fixture-baseline-compatibility\.sh$' ||
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
