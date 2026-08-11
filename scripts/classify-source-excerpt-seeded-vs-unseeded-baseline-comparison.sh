#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY SOURCE-EXCERPT SEEDED VS UNSEEDED BASELINE COMPARISON ==="

seeded_artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-source-excerpt-fixed-seed-once.xue4be"
unseeded_artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-source-excerpt-unseeded-once.0hlhV6"
failure_signature='Ollama returned a conversation support reference that was not supplied in this invocation.'

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY REQUIRED CLASSIFICATION CHECKPOINT ==="
required_checkpoint="1a9b68f7"

if ! git merge-base --is-ancestor "$required_checkpoint" HEAD; then
  echo "STOP: required source-excerpt fixed-seed failure classification $required_checkpoint is not an ancestor of HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-source-excerpt-seeded-vs-unseeded-baseline-comparison\.sh$|^ M scripts/classify-source-excerpt-seeded-vs-unseeded-baseline-comparison\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REQUIRED_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRESERVED SEEDED AND UNSEEDED ARTIFACTS ==="

for file in \
  "$seeded_artifact_dir/source-excerpt.stderr.txt" \
  "$unseeded_artifact_dir/source-excerpt.stderr.txt"
do
  if [[ ! -f "$file" ]]; then
    echo "STOP: required preserved artifact missing: $file"
    exit 2
  fi
done

echo "PRESERVED_COMPARISON_ARTIFACTS=CONFIRMED"

echo
echo "=== SEEDED FAILURE ==="
cat "$seeded_artifact_dir/source-excerpt.stdout.txt" 2>/dev/null || true
cat "$seeded_artifact_dir/source-excerpt.stderr.txt"

echo
echo "=== UNSEEDED FAILURE ==="
cat "$unseeded_artifact_dir/source-excerpt.stdout.txt" 2>/dev/null || true
cat "$unseeded_artifact_dir/source-excerpt.stderr.txt"

seeded_match=0
unseeded_match=0

grep -qF \
  "$failure_signature" \
  "$seeded_artifact_dir/source-excerpt.stderr.txt" &&
  seeded_match=1 || true

grep -qF \
  "$failure_signature" \
  "$unseeded_artifact_dir/source-excerpt.stderr.txt" &&
  unseeded_match=1 || true

echo
echo "SEEDED_CONVERSATION_SUPPORT_FAILURE=$seeded_match"
echo "UNSEEDED_CONVERSATION_SUPPORT_FAILURE=$unseeded_match"

if [[ "$seeded_match" -ne 1 || "$unseeded_match" -ne 1 ]]; then
  echo "STOP: seeded and unseeded artifacts do not reproduce the same expected failure surface."
  exit 2
fi

echo "MATCHING_FAILURE_SURFACE=CONFIRMED"

echo
echo "=== VERIFY FIXTURE DIFFERENCE REMAINS SEED ONLY ==="

python3 <<'PY'
from pathlib import Path

baseline = Path("scripts/validate-source-excerpt-first-live.ts").read_text()
seeded = Path("scripts/validate-source-excerpt-first-fixed-seed-live.ts").read_text()
seed_line = "      validationGenerationSeed: 424242,\n"

if seeded.count(seed_line) != 1:
    raise SystemExit("STOP: fixed-seed fixture does not contain exactly one seed insertion")

if seeded.replace(seed_line, "", 1) != baseline:
    raise SystemExit("STOP: seeded and unseeded fixtures differ beyond seed insertion")

print("SEEDED_VS_UNSEEDED_FIXTURE_DIFFERENCE=SEED_ONLY")
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
UNIT=SOURCE_EXCERPT_SEEDED_VS_UNSEEDED_BASELINE_COMPARISON

SEEDED_RESULT=
  UNSUPPLIED_CONVERSATION_SUPPORT_REFERENCE_FAILURE

UNSEEDED_RESULT=
  UNSUPPLIED_CONVERSATION_SUPPORT_REFERENCE_FAILURE

SEEDED_VS_UNSEEDED_FAILURE_SURFACE=
  MATCHES

FIXED_SEED_SPECIFIC_REGRESSION=
  NOT_ESTABLISHED

FIXED_SEED_CANDIDATE_STATUS=
  NOT_DISQUALIFIED_BY_THIS_COMPARISON

DETERMINISTIC_RUNTIME_STATUS=
  CORRECT_FAIL_CLOSED_ENFORCEMENT

DIRECT_COMPARISON_CLASSIFICATION=
  The source-excerpt-first fixed-seed fixture and its original unseeded
  baseline fail on the same conversation-support provenance boundary.

  Because validationGenerationSeed=424242 is the only fixture difference,
  this direct comparison does not support attributing the failure to the
  fixed seed.

FIXTURE_ADMISSIBILITY=
  NOT_ADMISSIBLE_FOR_FIXED_SEED_SEMANTIC_PRESERVATION_COMPARISON

RATIONALE=
  The fixture independently satisfies selected-context candidate identity
  requirements, but both seeded and unseeded runs author a conversation
  support reference that was not supplied in the invocation.

  Therefore this fixture currently fails an established support-provenance
  boundary before it can provide discriminating evidence about fixed-seed
  semantic preservation.

WIDER_SEMANTIC_PRESERVATION_EVIDENCE=
  INSUFFICIENT

CURRENT_DIAGNOSTIC_EVIDENCE=
  Adaptive Detail:
    fixed seed eliminated the known project-context parent-support failure
    across the bounded ten-run sample.

  Reasoning / Explanation:
    seeded and unseeded fixtures both fail the selected-context contract.

  Structured Evidence:
    seeded and unseeded fixtures both fail the selected-context contract.

  Source Excerpt First:
    seeded and unseeded fixtures both fail the conversation-support contract.

INTERPRETATION=
  Current repository evidence supports fixed-seed stabilization of the known
  Adaptive Detail failure surface.

  Current repository evidence does not yet establish wider semantic
  preservation because the additional candidate live fixtures fail existing
  deterministic contracts in both seeded and unseeded form.

  No further seed-only adaptation should be created merely to accumulate
  passing evidence.

FIXTURE_REPAIR_AUTHORIZED=NO
NEW_SEEDED_FIXTURE_AUTHORIZED=NO
SEED_CHANGE_AUTHORIZED=NO
PROMPT_CHANGE_AUTHORIZED=NO
VALIDATOR_RELAXATION_AUTHORIZED=NO
REPEATED_WIDER_RUNS_AUTHORIZED=NO

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

WIDER_SEMANTIC_PRESERVATION_STATUS=
  BLOCKED_BY_INSUFFICIENT_ADMISSIBLE_REPOSITORY_LIVE_FIXTURES

NEXT_ACTION=
  CLASSIFY_GENERATION_CONTROL_SEMANTIC_PRESERVATION_CORRIDOR_DISPOSITION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-source-excerpt-seeded-vs-unseeded-baseline-comparison\.sh$' ||
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

git add scripts/classify-source-excerpt-seeded-vs-unseeded-baseline-comparison.sh
git diff --cached --check
git commit -m "Classify source excerpt seeded baseline comparison"
git push
