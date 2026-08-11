#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE STRUCTURED-RESPONSE RELIABILITY FAILURE SURFACE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY CORRIDOR-2 CLASSIFICATION CHECKPOINT ==="
expected_head="e0cdb130"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches Corridor 2 classification checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-structured-response-reliability-failure-surface\.sh$|^ M scripts/investigate-structured-response-reliability-failure-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CORRIDOR_2_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CORRIDOR-2 RESULT ==="
grep -nE \
  'SEMANTIC_FAILURE_CLASS=|MODEL_AUTHORED_INVALID_SUPPORT_PROVENANCE|DETERMINISTIC_RUNTIME_RESULT=|CORRECT_FAIL_CLOSED_ENFORCEMENT|CORRIDOR_2_RESULT=|UNSEEDED_ACCEPTANCE_BOUNDARY_VARIANCE_CONFIRMED|NEXT_CORRIDOR=STRUCTURED_RESPONSE_RELIABILITY_CHARACTERIZATION' \
  scripts/classify-preserved-unseeded-acceptance-boundary-failure.sh

echo "CORRIDOR_2_RESULT=CONFIRMED"

echo
echo "=== STRUCTURED RESPONSE PARSE AND VALIDATION SURFACE ==="
sed -n '420,720p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT REFERENCE POST-GENERATION VALIDATION SURFACE ==="
sed -n '990,1115p' scripts/utils/ollamaChat.ts

echo
echo "=== PROMPT INSTRUCTIONS FOR SUPPORT PROVENANCE ==="
sed -n '840,890p' scripts/utils/ollamaChat.ts

echo
echo "=== PROJECT CONTEXT SERIALIZATION / IDENTITY SURFACE ==="
grep -nE \
  'projectContext|project_context|relativePath|sourceStartLine|sourceEndLine|lineNumber|supportSourceReferences|selectedContextSegments' \
  scripts/utils/ollamaChat.ts |
  head -160

echo
echo "=== MIXED-CONTENT FIXTURE ==="
sed -n '1,220p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== FIXTURE SOURCE MATERIAL ==="
if [[ -f docs/adaptive-detail-live-validation.md ]]; then
  nl -ba docs/adaptive-detail-live-validation.md
else
  echo "docs/adaptive-detail-live-validation.md not present as repository file."
fi

echo
echo "=== RELEVANT CONTRACT TEST SURFACES ==="
find scripts -maxdepth 2 -type f |
  sort |
  grep -Ei \
    'ollama.*contract|support.*reference|structured.*response|adaptive-detail.*criteria|source.*excerpt' \
  || true

echo
echo "=== SUPPORT-REFERENCE VALIDATION TEST SIGNALS ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'project-context support reference that was not supplied|supportSourceReferences.*supplied|lineNumber.*sourceStartLine|sourceStartLine.*lineNumber|project_context_excerpt' \
  scripts \
  server \
  2>/dev/null |
  head -220 || true

echo
echo "=== INVESTIGATION FINDINGS ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=STRUCTURED_RESPONSE_RELIABILITY_CHARACTERIZATION

ESTABLISHED_INPUT=
  Corridor 2 demonstrated one accepted result and nine rejected results across
  ten identical ordinary unseeded invocations.

ESTABLISHED_FAILURE_CLASS=
  MODEL_AUTHORED_INVALID_SUPPORT_PROVENANCE

ESTABLISHED_RUNTIME_BEHAVIOR=
  CORRECT_FAIL_CLOSED_ENFORCEMENT

CORRIDOR_3_QUESTION=
  Why does ordinary unseeded semantic generation repeatedly author a
  project-context support identity that is not valid for the supplied
  invocation, and which existing boundary owns that reliability problem?

INVESTIGATION_SCOPE=
  - project-context identity presented to the model;
  - supportSourceReferences prompt instructions;
  - structured-response parsing;
  - model-authored support-reference identity;
  - post-generation deterministic provenance validation;
  - fixture-specific supplied context and acceptance criteria.

BOUNDARIES_NOT_YET_AUTHORIZED_FOR_CHANGE=
  - generation seed;
  - temperature;
  - top_p;
  - top_k;
  - retries;
  - additional model invocations;
  - production workflow;
  - semantic history;
  - Response Composition;
  - deterministic fail-closed validation.

CURRENT_HYPOTHESIS_STATUS=
  UNCLASSIFIED

  Corridor 2 proves the output failure exists but does not yet prove whether
  the smallest responsible surface is prompt representation, source identity
  representation, model semantic reliability, or another existing structured
  response boundary.

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_ACTION=CLASSIFY_STRUCTURED_RESPONSE_RELIABILITY_FAILURE_SURFACE
MAP

echo
echo "=== VERIFY INVESTIGATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/investigate-structured-response-reliability-failure-surface\.sh$' ||
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

git add scripts/investigate-structured-response-reliability-failure-surface.sh
git diff --cached --check
git commit -m "Investigate structured response reliability failure surface"
git push
