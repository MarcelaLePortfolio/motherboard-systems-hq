#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 3 — SURFACING SURFACE INVESTIGATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor c8760f6a HEAD

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-phase-3-corridor-3-surfacing-surfaces\.sh$|^ M scripts/investigate-phase-3-corridor-3-surfacing-surfaces\.sh$' ||
  true
)"
test -z "$unexpected"

printf '\n--- EXPLANATION STATUS DEFINITIONS / USAGE ---\n'
grep -RIn -B12 -A30 -E \
'explanationStatus|MatildaExplanationStatus' \
scripts server app routes components \
--include='*.ts' \
--include='*.tsx' \
2>/dev/null | head -n 700

printf '\n--- USER-FACING REPLY CONSUMPTION ---\n'
grep -RIn -B14 -A40 -E \
'ollamaResult\.reply|result\.reply|assistantReply|reply:' \
server app routes components \
--include='*.ts' \
--include='*.tsx' \
2>/dev/null | head -n 700

printf '\n--- RESPONSE / WORKFLOW TRANSPORT ---\n'
grep -RIn -B18 -A45 -E \
'ollamaChat\(|OllamaChatResult|durableInterpretation|explanationStatus' \
server routes \
--include='*.ts' \
2>/dev/null | head -n 800

printf '\n--- UI SURFACING CANDIDATES ---\n'
grep -RIn -B18 -A45 -E \
'assistant.*message|message\.content|reply|reasoning|explanation' \
app components \
--include='*.tsx' \
--include='*.ts' \
2>/dev/null | head -n 800

cat <<'MAP'

PHASE_3=REASONING_STATUS_PRODUCTION_BEHAVIOR
CORRIDOR_3=SURFACING_CONTRACT
STATUS=ACTIVE
MODE=COLLABORATION
IMPLEMENTATION_AUTHORIZED=NO

INVESTIGATION_GOAL=
IDENTIFY_WHERE_EXPLANATION_STATUS_CURRENTLY_TRAVELS_AND_WHERE_THE_USER_VISIBLE_REPLY_IS_RENDERED_SO_THE_SMALLEST_SURFACING_CONTRACT_CAN_BE_CLASSIFIED

REQUIRED_CARRY_FORWARD_LIMIT=
DO_NOT_CLAIM_REASONING_STATUS_MODEL_BEHAVIORAL_RELIABILITY

DO_NOT_CHANGE=
PROMPT__SCHEMA__WORKFLOW_AUTHORITY__UI__INVOCATION_COUNT__RETRY_POLICY

PRODUCTION_CHANGE=
NONE

DR_NOW=
NO

NEXT_ACTION=
CLASSIFY_WHETHER_SURFACING_CAN_BE_ACHIEVED_WITH_REPLY_COMPOSITION_ONLY_OR_REQUIRES_EXPLICIT_WORKFLOW_OR_UI_CONSUMPTION_OF_EXPLANATION_STATUS
MAP
