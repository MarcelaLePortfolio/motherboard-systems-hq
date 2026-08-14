#!/usr/bin/env bash
set -euo pipefail

echo "=== IMPLEMENT EXPERIMENTAL PRESENTATION PRODUCTION PROMOTION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor 7fa5786f HEAD
test -z "$(git status --porcelain)"

authorization="scripts/authorize-experimental-presentation-production-promotion.sh"
target="scripts/utils/ollamaChat.ts"

test -f "$authorization"
test -f "$target"

grep -q 'PRODUCTION_PROMOTION_IMPLEMENTATION_AUTHORIZED=' "$authorization"
grep -q '^YES$' \
  <(awk '/PRODUCTION_PROMOTION_IMPLEMENTATION_AUTHORIZED=/{getline; print}' "$authorization")

grep -q 'PRODUCTION_REMEDY_AUTHORIZED=' "$authorization"
grep -q '^YES_BOUNDED_TO_PROMPT_PRESENTATION_STRUCTURE$' \
  <(awk '/PRODUCTION_REMEDY_AUTHORIZED=/{getline; print}' "$authorization")

python3 - <<'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = '''const validationPromptPresentation =
    context.validationPromptPresentationVariant ===
    "explicit_parent_child_separation"
      ? ['''

new = '''const validationPromptPresentation =
    context.validationPromptPresentationVariant === undefined ||
    context.validationPromptPresentationVariant ===
      "explicit_parent_child_separation"
      ? ['''

if old not in text:
    raise SystemExit("STOP: expected validated presentation selector block not found")

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo "=== VERIFY PROMOTION SHAPE ==="
grep -n -A4 -B2 'const validationPromptPresentation' "$target"
git diff --check

echo "=== TARGETED TYPESCRIPT VALIDATION ==="
npx tsc \
  --noEmit \
  --pretty false \
  --target ES2022 \
  --module nodenext \
  --moduleResolution nodenext \
  --esModuleInterop \
  --skipLibCheck \
  "$target"

echo "TARGETED_TYPESCRIPT_VALIDATION=PASS"

cat <<'MAP'
IMPLEMENTATION_UNIT=
EXPERIMENTAL_PRESENTATION_PRODUCTION_PROMOTION

PRODUCTION_DEFAULT_PRESENTATION=
EXPLICIT_PARENT_CHILD_SEPARATION

CHANGE_CLASS=
PROMPT_PRESENTATION_STRUCTURE_ONLY

SEMANTIC_CONTRACT_CHANGE=
NONE

STRUCTURED_RESPONSE_SCHEMA_CHANGE=
NONE

SUPPORT_PROVENANCE_RULE_CHANGE=
NONE

SELECTED_CONTEXT_SEGMENT_RULE_CHANGE=
NONE

FAIL_CLOSED_VALIDATOR_CHANGE=
NONE

MODEL_CHANGE=
NONE

GENERATION_POLICY_CHANGE=
NONE

RETRY_OR_SECOND_MODEL_CALL=
NONE

ONE_WORKFLOW_ONE_OLLAMA_INVOCATION=
PRESERVED

PRODUCTION_CHANGE=
PROMPT_PRESENTATION_DEFAULT_PROMOTED

IMPLEMENTATION_STATUS=
COMPLETE_PENDING_REGRESSION_VALIDATION

NEXT_ACTION=
RUN_POST_PROMOTION_REGRESSION_VALIDATION
MAP
