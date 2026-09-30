#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

printf '\n=== BASELINE ===\n'
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== LIVE DELEGATION / ENVELOPE ENTRY SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'delegat(e|ion)|handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelopeRouter|consumeProductionEnvelopeEntryPoint|production-envelope-entry-point|/api/governance/envelope' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== POST-ENVELOPE COMPOSITION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B20 -A70 \
  'composeProductionPostEnvelopeLifecycle|production-post-envelope-lifecycle-composition|handoffProductionEnvelopeToLifecycle' \
  server db routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== MISSION READ / OPERATIONAL INTAKE SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A55 \
  'Mission Read|mission_read|missionRead|operational_intake|operational intake|active_mission|activeMission' \
  server db routes client/src \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'POST_ENVELOPE_IMPLEMENTATION_BOUNDARY=CLOSED'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'QUESTION=WHAT_EXISTING_LIVE_CALLER_ACCEPTS_A_REAL_DELEGATION_AND_REACHES_THE_PRODUCTION_ENVELOPE_PATH'
echo 'IMPLEMENTATION_ALLOWED_BY_THIS_STEP=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'NEXT_STEP=CLASSIFY_EXACT_LIVE_DELEGATION_ENTRY_POINT_FROM_EVIDENCE_ABOVE'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'
