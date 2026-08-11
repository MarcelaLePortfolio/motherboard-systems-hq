#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY WIDER FIXED-SEED SINGLE-RUN FAILURE ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-wider-fixed-seed-once.qVjjMM"

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY DIAGNOSTIC FIXTURE CHECKPOINT ==="
required_checkpoint="96aeee4a"

if ! git merge-base --is-ancestor "$required_checkpoint" HEAD; then
  echo "STOP: required wider diagnostic fixture checkpoint $required_checkpoint is not an ancestor of HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-wider-fixed-seed-single-run-failure\.sh$|^ M scripts/classify-wider-fixed-seed-single-run-failure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "DIAGNOSTIC_FIXTURE_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRESERVED ARTIFACTS ==="
if [[ ! -d "$artifact_dir" ]]; then
  echo "STOP: preserved wider fixed-seed artifact directory is unavailable."
  exit 2
fi

for file in \
  "$artifact_dir/reasoning.stdout.txt" \
  "$artifact_dir/reasoning.stderr.txt" \
  "$artifact_dir/evidence.stdout.txt" \
  "$artifact_dir/evidence.stderr.txt"
do
  if [[ ! -f "$file" ]]; then
    echo "STOP: required preserved artifact missing: $file"
    exit 2
  fi
done

echo "PRESERVED_ARTIFACTS=CONFIRMED"

echo
echo "=== REASONING FAILURE ==="
cat "$artifact_dir/reasoning.stdout.txt"
cat "$artifact_dir/reasoning.stderr.txt"

echo
echo "=== STRUCTURED-EVIDENCE FAILURE ==="
cat "$artifact_dir/evidence.stdout.txt"
cat "$artifact_dir/evidence.stderr.txt"

failure_signature='Ollama returned a selected context segment that was not supplied in this invocation.'

reasoning_signature_count="$(
  grep -cF "$failure_signature" "$artifact_dir/reasoning.stderr.txt" || true
)"

evidence_signature_count="$(
  grep -cF "$failure_signature" "$artifact_dir/evidence.stderr.txt" || true
)"

echo
echo "REASONING_FAILURE_SIGNATURE_COUNT=$reasoning_signature_count"
echo "STRUCTURED_EVIDENCE_FAILURE_SIGNATURE_COUNT=$evidence_signature_count"

if [[ "$reasoning_signature_count" -ne 1 ]]; then
  echo "STOP: reasoning artifact does not contain the expected selected-context failure signature."
  exit 2
fi

if [[ "$evidence_signature_count" -ne 1 ]]; then
  echo "STOP: structured-evidence artifact does not contain the expected selected-context failure signature."
  exit 2
fi

echo "COMMON_FAILURE_SIGNATURE=CONFIRMED"

echo
echo "=== VERIFY SEEDED ADAPTATIONS ARE SEED-ONLY ==="
python3 <<'PY'
from pathlib import Path

pairs = [
    (
        Path("scripts/validate-reasoning-composition-live.ts"),
        Path("scripts/validate-reasoning-composition-fixed-seed-live.ts"),
    ),
    (
        Path("scripts/validate-structured-evidence-object-live.ts"),
        Path("scripts/validate-structured-evidence-object-fixed-seed-live.ts"),
    ),
]

seed_line = "      validationGenerationSeed: 424242,\n"

for source_path, adapted_path in pairs:
    source = source_path.read_text()
    adapted = adapted_path.read_text()

    if adapted.count(seed_line) != 1:
        raise SystemExit(
            f"STOP: expected exactly one seed insertion in {adapted_path}"
        )

    if adapted.replace(seed_line, "", 1) != source:
        raise SystemExit(
            f"STOP: {adapted_path} differs from source beyond seed insertion"
        )

print("SEEDED_ADAPTATIONS_REMAIN_SEED_ONLY=CONFIRMED")
PY

echo
echo "=== INSPECT FIXTURE CONTEXT INPUTS ==="
for file in \
  scripts/validate-reasoning-composition-live.ts \
  scripts/validate-structured-evidence-object-live.ts
do
  echo
  echo "--- $file ---"
  grep -nE \
    'ollamaChat\(|projectContextExcerpts|projectContextSegmentCandidates|selectedContextSegments|validationGenerationSeed' \
    "$file" || true
done

echo
echo "=== INSPECT SELECTED-CONTEXT FAIL-CLOSED VALIDATOR ==="
grep -n -A70 -B30 \
  'selected context segment that was not supplied in this invocation' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=WIDER_FIXED_SEED_SINGLE_RUN_FAILURE_CLASSIFICATION

OBSERVED_RESULT=
  The first fixed-seed Reasoning / Explanation diagnostic failed closed.

  The first fixed-seed Structured Evidence diagnostic failed closed.

COMMON_FAILURE_SIGNATURE=
  Ollama returned a selected context segment that was not supplied in this
  invocation.

FIXTURE_ADAPTATION_STATUS=
  SEED_ONLY_DIFFERENCE_CONFIRMED

DETERMINISTIC_RUNTIME_STATUS=
  CORRECT_FAIL_CLOSED_ENFORCEMENT

FAILURE_CLASS=
  MODEL_AUTHORED_UNSUPPLIED_SELECTED_CONTEXT_IDENTITY

RELATIONSHIP_TO_PRIOR_FIXED_SEED_SUCCESS=
  DIFFERENT_STRUCTURED_SEMANTIC_FAILURE_SURFACE

  The prior Adaptive Detail fixed-seed diagnostic demonstrated that seed 424242
  stabilized the known parent-support identity failure in that fixture.

  These wider fixtures expose a different failure: model-authored selected
  context identity where no valid supplied child identity supports that output.

FIXED_SEED_CANDIDATE_STATUS=
  NOT_YET_DISQUALIFIED
  NOT_YET_WIDER_SEMANTICALLY_PRESERVED

CURRENT_HYPOTHESIS_BOUNDARY=
  It is not yet established whether:

  - the same selected-context failure occurs in the original unseeded live
    fixtures;
  - fixed seeding introduces or increases this failure;
  - the existing live fixtures predate the selectedContextSegments contract and
    are no longer sufficient as wider preservation fixtures;
  - another repository-supported fixture is required.

NO_FIX_AUTHORIZED=
  Do not add projectContextSegmentCandidates merely to make the seeded fixtures
  pass.

  Do not alter prompt instructions.

  Do not relax selected-context validation.

  Do not change the seed.

  Do not add retries.

  Do not proceed to repeated wider fixed-seed runs.

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

WIDER_SEMANTIC_PRESERVATION_RESULT=
  BLOCKED_PENDING_BASELINE_COMPARISON

NEXT_ACTION=
  RUN_ORIGINAL_UNSEEDED_REASONING_AND_STRUCTURED_EVIDENCE_FIXTURES_ONCE_FOR_DIRECT_BASELINE_COMPARISON
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-wider-fixed-seed-single-run-failure\.sh$' ||
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

git add scripts/classify-wider-fixed-seed-single-run-failure.sh
git diff --cached --check
git commit -m "Classify wider fixed seed single run failure"
git push
