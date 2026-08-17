#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 1 — CLASSIFICATION RULE INVESTIGATION ==="

printf '%s\n' '--- CURRENT STRUCTURED EXPLANATION STATUS CONTRACT ---'
sed -n '25,48p' scripts/utils/ollamaChat.ts
sed -n '250,275p' scripts/utils/ollamaChat.ts
sed -n '450,472p' scripts/utils/ollamaChat.ts
sed -n '675,716p' scripts/utils/ollamaChat.ts

printf '\n--- CURRENT PRODUCTION REPLY / EXPLANATION INSTRUCTIONS ---\n'
sed -n '917,960p' scripts/utils/ollamaChat.ts

printf '\n--- ORIGINAL V3 REASONING CLASSIFICATION SEMANTICS ---\n'
git show 097575be:scripts/utils/ollamaChat.ts 2>/dev/null |
  grep -n -B4 -A12 -E 'Reasoning Status: Optional|Reasoning Status: Recommended|Optional is the default|materially change' ||
  true

printf '\n--- REFINED V3 REASONING CLASSIFICATION SEMANTICS ---\n'
git show 53e396d3:scripts/utils/ollamaChat.ts 2>/dev/null |
  grep -n -B4 -A14 -E 'Reasoning Status: Optional|Reasoning Status: Recommended|Optional is the default|materially change' ||
  true

printf '\n--- CURRENT EXPLANATION STATUS TEST SEMANTICS ---\n'
grep -n -B8 -A30 -E 'explanationStatus|optional|recommended' \
  scripts/utils/ollamaChat.explanation-status.test.ts 2>/dev/null |
  head -n 260 || true

printf '\n--- WORKFLOW CONSUMPTION / SURFACING BOUNDARY ---\n'
grep -RInE 'explanationStatus|Reasoning Status' \
  app server components lib scripts \
  --exclude-dir=node_modules \
  --exclude='*.sh' \
  2>/dev/null |
  head -n 300 || true

cat <<'MAP'

INVESTIGATION_BOUNDARY=
CLASSIFICATION_SEMANTICS_ONLY

KNOWN_CURRENT_CAPABILITY=
STRUCTURED_EXPLANATION_STATUS_OPTIONAL_OR_RECOMMENDED

KNOWN_CURRENT_VALIDATION=
ENUM_AND_FAIL_CLOSED_VALIDATION_EXIST

KNOWN_GAP_FROM_STARTING_EVIDENCE=
EXPLICIT_V3_OPTIONAL_VS_RECOMMENDED_SELECTION_RULE_NOT_YET_FOUND_ON_CURRENT_PRODUCTION_PROMPT_SURFACE

QUESTION_TO_RESOLVE=
WHETHER_THE_HISTORICAL_V3_SELECTION_RULE_IS_THE_CANONICAL_SEMANTIC_RULE_TO_PRESERVE_IN_CURRENT_EXPLANATION_STATUS

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE
MAP
