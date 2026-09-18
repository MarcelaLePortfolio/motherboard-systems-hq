#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== CURRENT CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "FAILURE_LOCATION=INITIAL_BEFORE_TARGET_ENTRIES_IEL_READ"
echo "WORKFLOW_EXECUTED_BEFORE_FAILURE=NO"
echo "ATLAS_LIFECYCLE_ASSERTIONS_REACHED=NO"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

printf '\n=== EXACT INITIAL IEL READ CALL ===\n'
sed -n '235,275p' "$TEST"

printf '\n=== IEL RUNTIME TABLE ENSURE + READ QUERY ===\n'
sed -n '1,130p' db/matilda-interpretation-runtime.ts
sed -n '440,550p' db/matilda-interpretation-runtime.ts

printf '\n=== CONVERSATION RUNTIME INITIALIZATION ORDER ===\n'
grep -n -B15 -A80 -E \
  'new Database|db/main\.db|CREATE TABLE|matilda_conversations|matilda_interpretation_evidence_ledger' \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  || true

printf '\n=== CHECK IEL TABLE SHAPE EXPECTED BY CURRENT READER ===\n'
grep -n -A40 -B5 \
  'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

printf '\n=== CHECK MIGRATION / ALTER HISTORY FOR IEL COLUMNS ===\n'
git grep -n -E \
  'matilda_interpretation_evidence_ledger|investigation_lifecycle_json|package_semantics_json|supersession_status' \
  -- db server scripts \
  | head -320 || true

printf '\n=== CHECK TEST SETUP BEFORE INITIAL IEL READ ===\n'
sed -n '180,275p' "$TEST"

printf '\n=== STATIC SCHEMA CONSISTENCY CHECK ===\n'
python3 - <<'PY'
from pathlib import Path
import re

runtime = Path("db/matilda-interpretation-runtime.ts").read_text()

create = re.search(
    r'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger\s*\((.*?)\)\s*`',
    runtime,
    re.S,
)

select = re.search(
    r'SELECT\s+(.*?)\s+FROM matilda_interpretation_evidence_ledger',
    runtime,
    re.S,
)

if not create or not select:
    print("SCHEMA_CHECK=UNRESOLVED")
    raise SystemExit(0)

created = set(
    re.findall(r'^\s*([a-zA-Z_][a-zA-Z0-9_]*)\s+[A-Z]', create.group(1), re.M)
)

selected = set(
    re.findall(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\b', select.group(1))
)

known = {
    "entry_id",
    "created_at",
    "actor",
    "project_id",
    "conversation_id",
    "interpretation_event",
    "minimum_sufficient_context",
    "supporting_raw_evidence",
    "matilda_observation",
    "unresolved_questions",
    "lineage_references",
    "investigation_lifecycle_json",
    "package_semantics_json",
    "supersession_status",
}

selected &= known

print("CREATED_COLUMNS=" + ",".join(sorted(created)))
print("SELECTED_COLUMNS=" + ",".join(sorted(selected)))
print("SELECTED_NOT_CREATED=" + ",".join(sorted(selected - created)))
print(
    "SCHEMA_CHECK=" +
    ("PASS" if not (selected - created) else "FAIL")
)
PY

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY AUTHORIZED TEST STILL ONLY TEST DIFF ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== STOPPING POINT ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_INITIAL_IEL_SCHEMA_OR_INITIALIZATION_FAILURE"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
