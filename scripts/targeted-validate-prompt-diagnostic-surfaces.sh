#!/usr/bin/env bash
set -euo pipefail

echo "=== TARGETED VALIDATE PROMPT DIAGNOSTIC SURFACES ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 4387f3dd HEAD

ollama="scripts/utils/ollamaChat.ts"
runner="scripts/run-bounded-prompt-presentation-diagnostic.ts"

test -f "$ollama"
test -f "$runner"

echo "=== VERIFY EXPECTED PARTIAL IMPLEMENTATION ==="
grep -q 'validationPromptPresentationVariant' "$ollama"
grep -q 'explicit_parent_child_separation' "$ollama"
grep -q 'Validation-only project-context identity presentation:' "$ollama"
grep -q 'validationPromptPresentationVariant' "$runner"
echo "EXPECTED_DIAGNOSTIC_SURFACES=CONFIRMED"

echo "=== TARGETED TYPESCRIPT CHECK ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  "$ollama" \
  "$runner"
echo "TARGETED_TYPESCRIPT_CHECK=PASS"

echo "=== DIFF CHECK ==="
git diff --check
echo "DIFF_CHECK=PASS"

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

PHASE_2=
GENERATION_LAYER_INTERVENTION_INVESTIGATION

CORRIDOR_1=
PROMPT_AND_RESPONSE_CONTRACT_PRESENTATION

VALIDATION_UNIT=
TARGETED_DIAGNOSTIC_SURFACE_VALIDATION

TARGETED_TYPESCRIPT_CHECK=
PASS

FULL_REPOSITORY_TYPECHECK=
BLOCKED_BY_PRE_EXISTING_ATLAS_TS2554

ATLAS_CHANGE=
NONE

DIAGNOSTIC_SURFACES=
VALIDATED

PRODUCTION_CHANGE=
NONE

NEXT_ACTION=
COMMIT_VALIDATED_DIAGNOSTIC_SURFACES
MAP
