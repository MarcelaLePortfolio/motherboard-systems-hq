#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY STRUCTURED-RESPONSE RELIABILITY FAILURE SURFACE ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY INVESTIGATION CHECKPOINT ==="
expected_head="297e2d15"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches structured-response reliability investigation checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-structured-response-reliability-failure-surface\.sh$|^ M scripts/classify-structured-response-reliability-failure-surface\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "INVESTIGATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PARENT VS CHILD IDENTITY PRESENTATION ==="
grep -nE \
  'Source: \$\{item\.relativePath\}:\$\{item\.lineNumber\}|relativePath = \$\{item\.relativePath\}|sourceStartLine = \$\{item\.sourceStartLine\}|sourceEndLine = \$\{item\.sourceEndLine\}' \
  scripts/utils/ollamaChat.ts

echo "DISTINCT_PARENT_AND_CHILD_IDENTITY_PRESENTATION=CONFIRMED"

echo
echo "=== VERIFY EXPLICIT SUPPORT-IDENTITY PROMPT RULES ==="
grep -nF \
  'For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity.' \
  scripts/utils/ollamaChat.ts

grep -nF \
  'Do not invent, reconstruct, approximate, or reference a source identifier that was not supplied in this invocation.' \
  scripts/utils/ollamaChat.ts

echo "EXPLICIT_SUPPORT_IDENTITY_PROMPT_RULES=CONFIRMED"

echo
echo "=== VERIFY FIXTURE IDENTITY COLLISION SHAPE ==="
grep -nE \
  'parentLineNumber = 20|sourceStartLine: 20|sourceEndLine: 20|sourceStartLine: 22|sourceEndLine: 22' \
  scripts/validate-adaptive-detail-mixed-content-live.ts

echo "FIXTURE_PARENT_CHILD_IDENTITY_SHAPE=CONFIRMED"

echo
echo "=== VERIFY DETERMINISTIC SUPPLIED-SOURCE VALIDATION ==="
grep -nE \
  'suppliedProjectContextSources|sourceKey|project-context support reference that was not supplied in this invocation' \
  scripts/utils/ollamaChat.ts

echo "DETERMINISTIC_SUPPLIED_SOURCE_VALIDATION=CONFIRMED"

echo
echo "=== VERIFY EXISTING HISTORICAL INVESTIGATION SIGNALS ==="
for file in \
  scripts/investigate-adaptive-detail-parent-support-identity-mismatch.sh \
  scripts/document-adaptive-detail-parent-support-identity-determination.sh \
  scripts/investigate-adaptive-detail-support-identity-failure-after-clarification.sh \
  scripts/document-adaptive-detail-support-identity-presentation-collision.sh
do
  if [[ -f "$file" ]]; then
    echo "--- $file ---"
    grep -nE \
      'parent|child|Source identity|Segment|lineNumber|sourceStartLine|collision|support identity|support provenance' \
      "$file" |
      head -80 || true
  fi
done

echo
echo "=== CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_GENERATION_STABILITY_CHARACTERIZATION
CORRIDOR=STRUCTURED_RESPONSE_RELIABILITY_CHARACTERIZATION

ESTABLISHED_FAILURE=
  Across the bounded ten-run ordinary unseeded sample, nine runs authored
  project_context_excerpt support identity line 22 even though the only
  supplied parent Source identity was line 20.

STRUCTURAL_INPUT_MODEL=
  The invocation presents two intentionally different project-context identity
  domains:

  1. Parent support provenance:
     project_context_excerpt + relativePath + lineNumber.

  2. Child semantic admission:
     relativePath + sourceStartLine + sourceEndLine.

  In the fixture, the supplied parent support identity is line 20 while child
  segment identities include lines 20 and 22.

PROMPT_CONTRACT=
  The current prompt explicitly instructs the model to:

  - use only Source identities from Bounded project context evidence for
    project_context_excerpt support;
  - never use Segment source line ranges or child segment line numbers as
    project_context_excerpt support identity;
  - never invent or approximate an unsupplied source identifier.

OBSERVED_MODEL_BEHAVIOR=
  Despite those explicit instructions, nine of ten unseeded runs converted the
  immaterial child Segment line 22 into a project_context_excerpt support
  lineNumber.

DETERMINISTIC_BOUNDARY=
  The post-generation validator compares model-authored parent support identity
  against the exact supplied parent Source identities and rejects line 22.

  That behavior is contract-preserving and must remain fail closed.

FAILURE_SURFACE_CLASSIFICATION=
  MODEL_RELIABILITY_AT_DUAL_PROJECT_CONTEXT_IDENTITY_BOUNDARY

FAILURE_MECHANISM=
  CHILD_SEGMENT_IDENTITY_MISAUTHORED_AS_PARENT_SUPPORT_IDENTITY

PROMPT_AMBIGUITY_CLASSIFICATION=
  NOT_ESTABLISHED_AS_MISSING_INSTRUCTION

  The current prompt already states the parent-versus-child distinction
  explicitly and prohibits the exact observed identity substitution.

SCHEMA_VALIDITY_CLASSIFICATION=
  STRUCTURALLY_VALID_BUT_SEMANTICALLY_UNSUPPLIED_IDENTITY

  line 22 satisfies the JSON schema's integer requirements, so schema parsing
  alone cannot reject it.

  The later invocation-aware provenance validator correctly rejects it because
  line 22 was not supplied as a parent project-context Source identity.

DETERMINISTIC_VALIDATOR_CLASSIFICATION=
  CORRECT_AND_REQUIRED

PRODUCTION_WORKFLOW_CLASSIFICATION=
  NOT_ESTABLISHED_AS_ROOT_CAUSE

SEMANTIC_HISTORY_CLASSIFICATION=
  OUTSIDE_THIS_FAILURE_SURFACE

GENERATION_POLICY_CLASSIFICATION=
  STILL_UNDETERMINED

  This investigation establishes a repeatable model reliability failure at a
  known structured semantic identity boundary.

  It does not yet establish whether seed, sampling controls, another generation
  control, identity representation changes, or some other bounded intervention
  is the correct production solution.

CORRIDOR_3_RESULT=
  STRUCTURED_RESPONSE_RELIABILITY_FAILURE_SURFACE_CLASSIFIED

IMPLEMENTATION_AUTHORIZED=NO
IMPLEMENTATION_STARTED=NO
PRODUCTION_CHANGE=NONE

NEXT_CORRIDOR=GENERATION_CONTROL_SURFACE_INVENTORY
NEXT_ACTION=RECONCILE_AVAILABLE_GENERATION_CONTROL_SURFACES_WITHOUT_INTERVENTION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-structured-response-reliability-failure-surface\.sh$' ||
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

git add scripts/classify-structured-response-reliability-failure-surface.sh
git diff --cached --check
git commit -m "Classify structured response reliability failure surface"
git push
