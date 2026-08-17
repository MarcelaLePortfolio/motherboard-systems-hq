#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 1 — CLASSIFICATION RULE FALSIFICATION ==="

printf '%s\n' '--- SEARCH FOR COMPETING CURRENT CLASSIFICATION SEMANTICS ---'
grep -RIn -B8 -A20 -E \
'Explanation Status|explanationStatus|Reasoning Status|Optional is the default|Recommended only|safely continue|materially (change|affect)' \
scripts server docs/governance \
--exclude-dir=node_modules \
--exclude='*.test.ts' \
--exclude='investigate-phase-3-classification-rule.sh' \
--exclude='falsify-phase-3-classification-rule.sh' \
2>/dev/null | head -n 420 || true

printf '\n--- HISTORICAL RULE LINEAGE ---\n'
git log --all --oneline --decorate -- \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.reasoning-classification.test.ts \
scripts/utils/ollamaChat.explanation-status.test.ts | head -n 100

printf '\n--- REVERT BOUNDARY ---\n'
git show --stat --summary 5b7f9809
git show --no-ext-diff --format=medium 5b7f9809 -- scripts/utils/ollamaChat.ts |
  sed -n '1,180p'

printf '\n--- STRUCTURED ARTIFACT SUCCESSOR BOUNDARY ---\n'
git show --no-ext-diff --format=medium f83062b4 -- scripts/utils/ollamaChat.ts |
  sed -n '1,220p'

cat <<'MAP'

FALSIFICATION_QUESTION=
DOES_CURRENT_REPOSITORY_EVIDENCE_ESTABLISH_A_COMPETING_OPTIONAL_VS_RECOMMENDED_SEMANTIC_RULE_OR_SHOW_THAT_THE_HISTORICAL_V3_RULE_WAS_REJECTED_SEMANTICALLY_RATHER_THAN_ONLY_AS_REPLY_PRESENTATION

CURRENT_EVIDENCE_BEFORE_FALSIFICATION=
STRUCTURED_EXPLANATION_STATUS_SURVIVES_WITH_OPTIONAL_AND_RECOMMENDED_ENUM_AND_FAIL_CLOSED_VALIDATION

HISTORICAL_RULE=
OPTIONAL_DEFAULT_RECOMMENDED_ONLY_WHEN_SKIPPING_REASONING_IS_LIKELY_TO_MATERIALLY_CHANGE_NEXT_ENGINEERING_DECISION

CRITICAL_DISTINCTION=
SEMANTIC_SELECTION_RULE_VS_REPLY_TEXT_CLASSIFICATION_LINE

IMPLEMENTATION_AUTHORIZED=
NO

PRODUCTION_CHANGE=
NONE
MAP
