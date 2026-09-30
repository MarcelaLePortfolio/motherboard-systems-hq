#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="fb8588fa1"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

printf '\n=== DIRECT CREATE GOVERNANCE DELEGATION CALLERS ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B30 -A90 \
  'createGovernanceDelegation\(' \
  server routes db \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.|db/governance-runtime\.ts' || true

printf '\n=== IMPORTERS OF GOVERNANCE DELEGATION CREATION ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B15 -A60 \
  'createGovernanceDelegation|governance-runtime' \
  server routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== REGISTERED ROUTES NEAR DELEGATION SURFACES ===\n'
grep -RniE \
  --include='*.ts' --include='*.mjs' \
  -B25 -A80 \
  'app\.(use|post|put|patch)|router\.(post|put|patch)|register.*route|delegat(e|ion)' \
  server routes \
  2>/dev/null \
  | grep -vE '\.test\.|\.spec\.' || true

printf '\n=== SERVER REGISTRATION SURFACE ===\n'
grep -nE \
  -B10 -A30 \
  'app\.use|app\.post|register|route|governance|delegat' \
  server/index.ts \
  2>/dev/null || true

printf '\n=== CLASSIFICATION ===\n'
echo 'CURRENT_OBJECTIVE=LIVE_END_TO_END_DELEGATED_TASK_VALIDATION'
echo 'KNOWN_PERSISTENCE_PRIMITIVE=createGovernanceDelegation'
echo 'QUESTION=WHICH_REGISTERED_LIVE_RUNTIME_SURFACE_CALLS_OR_OWNS_THIS_PRIMITIVE'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'LIVE_TASK_SUBMISSION_PERFORMED=NO'
echo 'NEW_AUTHORITY_ALLOWED=NO'
echo 'NEXT_STEP=CLASSIFY_LIVE_DELEGATION_ENTRY_POINT_FROM_DIRECT_CALLER_EVIDENCE'

printf '\n=== SCOPED SAFETY ===\n'
test -z "$(git diff --cached --name-only)"
AFTER_UNSTAGED="$(git diff --name-only)"
test "$BEFORE_UNSTAGED" = "$AFTER_UNSTAGED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

git add -- inspect-create-governance-delegation-live-callers.sh
git commit -m "Inspect live governance delegation callers"
git push origin "$BRANCH"
