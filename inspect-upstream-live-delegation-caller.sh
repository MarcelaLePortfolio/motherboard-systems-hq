#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== GOVERNANCE / DELEGATION ROUTE REGISTRATION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  'governance.*delegat|delegat.*governance|handleGovernanceEnvelopeRouteRequest|createGovernanceEnvelopeRouter|consumeProductionEnvelopeEntryPoint' \
  server routes db \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== EXPRESS ROUTER MOUNTS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A40 \
  'app\.use|router\.(post|put|patch)|/api/governance|governance.*route|delegation.*route' \
  server routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== ENVELOPE ENTRY POINT CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  'consumeProductionEnvelopeEntryPoint|handleGovernanceEnvelopeRouteRequest|production-envelope-entry-point' \
  server routes db \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== DELEGATION PERSISTENCE / AUTHORIZATION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  'governance_delegations|delegation_id|authorization_state.*AUTHORIZED|create.*delegation|persist.*delegation' \
  server routes db \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== CLASSIFICATION ===\n'
echo 'POST_ENVELOPE_IMPLEMENTATION_BOUNDARY=CLOSED'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'INVESTIGATION=UPSTREAM_LIVE_DELEGATION_CALLER'
echo 'IMPLEMENTATION_ALLOWED_BY_THIS_STEP=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'NEXT_STEP=IDENTIFY_REGISTERED_LIVE_ENTRY_POINT_AND_REQUIRED_EXISTING_AUTHORITY'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'
