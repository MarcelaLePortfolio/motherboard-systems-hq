#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
BASELINE="6358d172c"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION OPERATOR PRESENTATION BOUNDARY ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "HTTP_MOUNT_UNIT=CLOSED"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== VERIFIED HTTP READ SURFACE ====="
sed -n '1,260p' server/routes/atlas/preexecution.ts

echo
echo "===== CURRENT ATLAS UI SURFACE ====="
grep -n -A120 -B40 \
  'atlas-status-card\|Atlas Subsystem Status\|atlas-health\|atlas-status-details' \
  public/index.html | head -n 900 || true

echo
echo "===== CURRENT ATLAS UI LOGIC ====="
grep -RniE -B20 -A80 \
  'atlas-status|atlas-health|Atlas Subsystem|/atlas/|preexecution|pre-execution' \
  public/js public \
  --include='*.js' \
  --include='*.html' \
  2>/dev/null | head -n 2200 || true

echo
echo "===== PROJECT / CONVERSATION IDENTITY SOURCES IN UI ====="
grep -RniE -B20 -A70 \
  'activeProjectId|projectId|conversationId|conversation_id|activeConversation|currentConversation' \
  public/js public/index.html \
  --include='*.js' \
  --include='*.html' \
  2>/dev/null | head -n 2200 || true

echo
echo "===== CLASSIFICATION QUESTIONS ====="
echo "Q1=SHOULD_PREEXECUTION_OBSERVABILITY_APPEAR_INSIDE_EXISTING_ATLAS_STATUS_CARD_OR_SEPARATE_OPERATOR_SURFACE"
echo "Q2=WHAT_EXISTING_UI_SOURCE_PROVIDES_ACTIVE_PROJECT_ID"
echo "Q3=WHAT_EXISTING_UI_SOURCE_PROVIDES_ACTIVE_CONVERSATION_ID"
echo "Q4=CAN_UI_CALL_GET_ATLAS_PREEXECUTION_WITHOUT_INVENTING_SCOPE"
echo "Q5=WHAT_MINIMUM_FIELDS_SHOULD_BE_PRESENTED_TO_PRESERVE_SOURCE_AND_AUTHORITY_DISTINCTIONS"
echo "Q6=HOW_SHOULD_MATILDA_AUTHORED_INTERPRETIVE_EVIDENCE_BE_LABELED"
echo "Q7=HOW_SHOULD_LIVING_DRAFT_PENDING_AND_CANONICAL_AUTHORITY_STATES_BE_DISPLAYED_WITHOUT_COLLAPSE"
echo "Q8=SHOULD_RAW_OBSERVATIONS_OR_ONLY_LINEAGE_GROUPED_STRUCTURAL_SEQUENCE_BE_OPERATOR_VISIBLE"
echo "Q9=WHAT_LABELS_PREVENT_CHRONOLOGY_FROM_BEING_READ_AS_CAUSATION"
echo "Q10=CAN_PRESENTATION_BE_ADDITIVE_WITHOUT_RESTORING_OR_REPLACING_LEGACY_DASHBOARD_BEHAVIOR"

echo
echo "===== HARD INVARIANTS ====="
echo "PREEXECUTION_AS_EXECUTION_HISTORY=FORBIDDEN"
echo "PREEXECUTION_AS_CAUSAL_EXPLANATION=FORBIDDEN"
echo "AUTHORITY_COLLAPSE=FORBIDDEN"
echo "MATILDA_AUTHORSHIP_ERASURE=FORBIDDEN"
echo "APPROVAL_INFERENCE=FORBIDDEN"
echo "MISSING_SCOPE_INFERENCE=FORBIDDEN"
echo "EXECUTION_ROUTE_CHANGE=FORBIDDEN"
echo "REASONER_CHANGE=FORBIDDEN"
echo "AGGREGATOR_CHANGE=FORBIDDEN"
echo "DATABASE_CHANGE=FORBIDDEN"
echo "DASHBOARD_RESTORATION_BY_ASSUMPTION=FORBIDDEN"

echo
echo "===== STOP BOUNDARY ====="
echo "UI_CHANGE=NONE"
echo "ROUTE_CHANGE=NONE"
echo "SERVER_MOUNT_CHANGE=NONE"
echo "REASONER_CHANGE=NONE"
echo "AGGREGATOR_CHANGE=NONE"
echo "MATILDA_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "IMPLEMENTATION=NONE"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "NEXT_ACTION=CLASSIFY_MINIMUM_OPERATOR_PRESENTATION_CONTRACT"

echo
echo "===== WORKTREE ====="
git status --short
