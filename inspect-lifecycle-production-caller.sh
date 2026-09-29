#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="98efb33a4"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

printf '\n=== LIFECYCLE PRODUCTION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  'completeGovernanceLifecycleAssignmentTransition|composeGovernanceLifecycleAssignmentTransition' \
  db server routes \
  2>/dev/null \
  | grep -vE '\.test\.' || true

printf '\n=== ENVELOPE / ASSIGNMENT / INTAKE PRODUCTION SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'ENVELOPE_CREATED|routing_ready|operational.*intake|assigned_department|department_handshake' \
  db server routes \
  2>/dev/null \
  | grep -vE '\.test\.' || true

printf '\n=== OPERATIONAL INTAKE RUNTIME ===\n'
if test -f db/operational-intake-runtime.ts; then
  cat db/operational-intake-runtime.ts
fi

printf '\n=== SERVER / ROUTE COMPOSITION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A50 \
  'operational-intake|governance-lifecycle|assignment-boundary|department-handshake' \
  server routes \
  2>/dev/null || true

printf '\n=== LIVE ENVELOPE AND LIFECYCLE ===\n'
sqlite3 -header -column db/main.db <<'SQL'
SELECT
  envelope_id,
  package_id,
  package_version,
  delegation_id,
  validation_status,
  lifecycle_state
FROM governance_envelopes
ORDER BY rowid DESC
LIMIT 5;

SELECT
  envelope_id,
  transition_authorization,
  persisted_at
FROM governance_lifecycle_events
ORDER BY rowid DESC
LIMIT 10;
SQL

printf '\n=== CLASSIFICATION ===\n'
echo 'KNOWN=LIFECYCLE_IMPLEMENTATION_EXISTS'
echo 'KNOWN=LIVE_ENVELOPE_REACHED_ENVELOPE_CREATED'
echo 'QUESTION=WHICH_EXISTING_PRODUCTION_COMPONENT_SHOULD_INVOKE_ASSIGNMENT_TRANSITION'
echo 'TARGET=EXACT_EXISTING_PRODUCTION_CALLER'
echo 'NEW_AUTHORITY_REQUIRED=NO'
echo 'IMPLEMENTATION_PERFORMED=NO'

printf '\n=== SAFETY ===\n'
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"
