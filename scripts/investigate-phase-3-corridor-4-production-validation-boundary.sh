#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 4 — PRODUCTION VALIDATION BOUNDARY INVESTIGATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor ec45efef HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-phase-3-corridor-4-production-validation-boundary\.sh$|^ M scripts/investigate-phase-3-corridor-4-production-validation-boundary\.sh$' ||
  true
)"
test -z "$unexpected"

echo "=== REASONING STATUS CONTRACT SURFACES ==="
grep -n -E 'explanationStatus|For explanationStatus:|For reply:|Use explanationStatus to govern|When explanationStatus is optional|When explanationStatus is recommended|Do not add a visible Reasoning Status' \
  scripts/utils/ollamaChat.ts || true

echo "=== REASONING STATUS TEST / VALIDATION SURFACES ==="
find scripts -maxdepth 3 -type f \
  \( -iname '*reasoning*status*' -o -iname '*reasoning*composition*' -o -iname '*generation*stability*' \) \
  -print | sort

echo "=== EXISTING LIVE / PRODUCTION-EQUIVALENT VALIDATION REFERENCES ==="
grep -RIn -E 'validationGenerationSeed|projectContextSegmentCandidates|selectedContextSegments|Ollama returned a selected context segment|FULL_SEMANTIC_PASS|FAIL_CLOSED_OR_RUNTIME_REJECTION|SEMANTIC_ACCEPTANCE_FAILURE|FIXTURE_SEMANTIC_PASS' \
  scripts \
  server \
  routes \
  --exclude-dir=node_modules \
  --exclude='*.map' \
  | head -n 300 || true

echo "=== CURRENT CONTRACT GUARDS ==="
npx tsx --test scripts/utils/ollamaChat.reasoning-status-surfacing.test.ts
bash scripts/guard-ollama-response-contract.sh

cat <<'MAP'
PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_4=PRODUCTION_VALIDATION_AND_CLOSURE
STATUS=INVESTIGATION_EVIDENCE_COLLECTED
MODE=COLLABORATION
IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE
DR_NOW=NO

CORRIDOR_3_DR=20260818_100454
CORRIDOR_3_SURFACING_CONTRACT=CLOSED_AND_PROTECTED
CORRIDOR_2_BEHAVIORAL_RELIABILITY_LIMIT=PRESERVED

INVESTIGATION_QUESTION=WHAT_PRODUCTION_VALIDATION_CAN_BE_PERFORMED_WITHOUT_REPEATING_THE_THREE_FAILED_SELECTED_CONTEXT_PATH_OR_MISREPRESENTING_PROMPT_CONTRACT_VALIDATION_AS_MODEL_BEHAVIORAL_RELIABILITY
NEXT_ACTION=CLASSIFY_CORRIDOR_4_PRODUCTION_VALIDATION_BOUNDARY_FROM_THIS_REPOSITORY_EVIDENCE
MAP
