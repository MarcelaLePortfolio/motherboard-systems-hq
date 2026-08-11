#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE COMPATIBLE WIDER SEMANTIC FIXTURES ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY COMPATIBILITY-CLASSIFICATION CHECKPOINT ==="
expected_head="e153463a"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches wider fixture compatibility checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-compatible-wider-semantic-fixtures\.sh$|^ M scripts/investigate-compatible-wider-semantic-fixtures\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "COMPATIBILITY_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY AUTHORIZED NEXT ACTION ==="
grep -nE \
  'BLOCKED_PENDING_COMPATIBLE_FIXTURE_CLASSIFICATION|INVESTIGATE_CURRENT_REPOSITORY_SUPPORTED_WIDER_SEMANTIC_FIXTURES_COMPATIBLE_WITH_SELECTED_CONTEXT_VALIDATION|FIXTURE_REPAIR_AUTHORIZED=|VALIDATOR_RELAXATION_AUTHORIZED=' \
  scripts/classify-wider-fixture-baseline-compatibility.sh

echo "INVESTIGATION_BOUNDARY=CONFIRMED"

echo
echo "=== INVENTORY LIVE VALIDATORS WITH PROJECT CONTEXT SEGMENT CANDIDATES ==="
grep -RIl \
  'projectContextSegmentCandidates' \
  scripts \
  --include='validate-*live.ts' \
  --include='validate-*-live.ts' \
  | sort || true

echo
echo "=== INVENTORY ALL VALIDATION-LIKE SURFACES WITH SEGMENT CANDIDATES ==="
grep -RIl \
  'projectContextSegmentCandidates' \
  scripts \
  --include='*.ts' \
  --include='*.sh' \
  | sort

echo
echo "=== INSPECT COMPATIBLE LIVE VALIDATOR INPUT SHAPES ==="
while IFS= read -r file; do
  [[ -z "$file" ]] && continue

  echo
  echo "--- $file ---"

  grep -nE \
    'ollamaChat\(|projectContextExcerpts|projectContextSegmentCandidates|sourceStartLine|sourceEndLine|validationGenerationSeed|supportSourceReferences|selectedContextSegments|durableInterpretation|explanationStatus|investigationLifecycle' \
    "$file" |
    head -180 || true
done < <(
  grep -RIl \
    'projectContextSegmentCandidates' \
    scripts \
    --include='validate-*live.ts' \
    --include='validate-*-live.ts' \
    | sort
)

echo
echo "=== INSPECT KNOWN ADAPTIVE DETAIL COMPATIBLE FIXTURE ==="
sed -n '1,240p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== SEARCH RESPONSIBILITY-SPECIFIC COMPATIBLE FIXTURES ==="

for responsibility in \
  reasoning \
  explanation \
  evidence \
  support \
  boundary \
  summary \
  investigation \
  durable
do
  echo
  echo "--- RESPONSIBILITY=$responsibility ---"

  grep -RIl \
    "$responsibility" \
    scripts \
    --include='*.ts' \
    --include='*.sh' |
    while IFS= read -r file; do
      if grep -q 'projectContextSegmentCandidates' "$file"; then
        echo "$file"
      fi
    done |
    sort -u || true
done

echo
echo "=== INVESTIGATION CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
UNIT=COMPATIBLE_WIDER_SEMANTIC_FIXTURE_INVESTIGATION

GOVERNING_QUESTION=
  Which current repository-supported semantic fixtures already satisfy the
  selected-context validation input contract strongly enough to serve as
  admissible seeded-versus-unseeded wider semantic comparisons?

COMPATIBILITY_REQUIREMENT=
  A candidate fixture that permits model-authored selectedContextSegments must
  supply projectContextSegmentCandidates with exact runtime identities.

  A fixture that supplies only projectContextExcerpts is not sufficient for
  this comparison when generated selected context is possible.

PREFERRED_FIXTURE_RULE=
  Prefer already-existing fixtures that:

  - exercise live Ollama semantic generation;
  - supply projectContextSegmentCandidates;
  - have independently established acceptance assertions;
  - cover a semantic responsibility beyond the known Adaptive Detail failure;
  - require no prompt, schema, validator, model, or production changes.

ADAPTIVE_DETAIL_STATUS=
  ALREADY_COMPATIBLE_AND_ALREADY_EXERCISED

REASONING_EXPLANATION_STATUS=
  INVESTIGATE_EXISTING_COMPATIBLE_SURFACE

EVIDENCE_SUPPORT_PROVENANCE_STATUS=
  INVESTIGATE_EXISTING_COMPATIBLE_SURFACE

OTHER_RESPONSIBILITY_STATUS=
  INVESTIGATE_ONLY_IF_REPOSITORY_ALREADY_CONTAINS_AN_ADMISSIBLE_LIVE_SURFACE

FIXTURE_REPAIR_AUTHORIZED=
  NO

NEW_FIXTURE_IMPLEMENTATION_AUTHORIZED=
  NO

SEED_CHANGE_AUTHORIZED=
  NO

VALIDATOR_RELAXATION_AUTHORIZED=
  NO

REPEATED_WIDER_RUNS_AUTHORIZED=
  NO

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

INVESTIGATION_RESULT=
  REPOSITORY_COMPATIBLE_FIXTURE_SURFACES_INVENTORIED

NEXT_ACTION=
  CLASSIFY_REPOSITORY_SUPPORTED_COMPATIBLE_WIDER_SEMANTIC_FIXTURE_SET
MAP

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-compatible-wider-semantic-fixtures\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside investigation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "INVESTIGATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/investigate-compatible-wider-semantic-fixtures.sh
git diff --cached --check
git commit -m "Investigate compatible wider semantic fixtures"
git push
