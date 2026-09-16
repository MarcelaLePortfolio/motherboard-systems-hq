#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean"

BRANCH="feature/support-source-references-runtime"
CHECKPOINT="7242e836a"

git fetch origin "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$CHECKPOINT"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$CHECKPOINT"
test -z "$(git diff --cached --name-only)"

echo "===== ATLAS PRE-EXECUTION READ MODEL — EVIDENCE CLASSIFICATION ====="
echo "MODE=READ_ONLY_COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "CHECKPOINT=$(git rev-parse HEAD)"

echo
echo "===== Q1 — CURRENT ATLAS INPUT ====="
sed -n '1,110p' server/atlas/atlas-unified-engine.ts

echo
echo "===== Q2 — EXECUTION EVENT READ PATH ====="
sed -n '1,100p' server/events/execution-event-bus.ts
sed -n '1,100p' server/events/execution-event-store.ts
sed -n '1,90p' server/routes/atlas/analyze.ts
sed -n '1,90p' server/routes/atlas/why.ts

echo
echo "===== Q3 — ATLAS INPUT TYPES ====="
grep -RniE \
  --include='*.ts' \
  'ExecutionEvent\[\]|runAtlasIntelligence\(|generateNarrative\(|reconstructWhy\(' \
  server/atlas server/routes/atlas routes/atlas 2>/dev/null || true

echo
echo "===== Q4 — PRE-EXECUTION -> ATLAS BRIDGE ====="
BRIDGE_MATCHES="$(
  grep -RniE \
    --include='*.ts' \
    --include='*.tsx' \
    --exclude-dir=node_modules \
    --exclude-dir=dist \
    '(interpretation|living.?draft|canonical.?package|investigation.?lifecycle|package.?semantics).{0,120}(atlas|runAtlasIntelligence|ExecutionEvent)|(atlas|runAtlasIntelligence|ExecutionEvent).{0,120}(interpretation|living.?draft|canonical.?package|investigation.?lifecycle|package.?semantics)' \
    server db routes scripts 2>/dev/null || true
)"

if [[ -n "$BRIDGE_MATCHES" ]]; then
  printf '%s\n' "$BRIDGE_MATCHES"
  echo "PREEXECUTION_TO_ATLAS_BRIDGE=EVIDENCE_FOUND_REQUIRES_TRACE"
else
  echo "PREEXECUTION_TO_ATLAS_BRIDGE=NO_EVIDENCE_FOUND"
fi

echo
echo "===== Q5 — EXISTING NON-AUTHORITATIVE READ SURFACES ====="
for FILE in \
  db/matilda-living-draft-read-runtime.ts \
  db/package-read-repository.ts \
  db/approval-request-repository.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-canonical-package-runtime.ts
do
  if [[ -f "$FILE" ]]; then
    echo
    echo "----- $FILE -----"
    grep -nE \
      'export function|SELECT |FROM matilda_|FROM governance_|list|read|get' \
      "$FILE" | head -n 180 || true
  fi
done

echo
echo "===== CLASSIFICATION ====="
echo "CURRENT_ATLAS_PRIMARY_INPUT=ExecutionEvent[]"
echo "EXECUTION_EVENT_READ_BOUNDARY=server/events/execution-event-bus.ts:getEvents"
echo "PERSISTENT_EXECUTION_EVENT_SOURCE=server/events/execution-event-store.ts"
echo "DURABLE_PREEXECUTION_STATE_EXISTS=YES"

if [[ -n "$BRIDGE_MATCHES" ]]; then
  echo "PRIMARY_MISSING_CAPABILITY=NOT_YET_CLASSIFIABLE"
  echo "NEXT_ACTION=TRACE_EXISTING_MATCHED_BRIDGE"
else
  echo "PREEXECUTION_ATLAS_PRODUCER=NONE_FOUND"
  echo "PRIMARY_MISSING_CAPABILITY=ATLAS_PREEXECUTION_READ_MODEL_BRIDGE"
  echo "REGRESSION=NOT_ESTABLISHED"
  echo "MATILDA_PREEXECUTION_PERSISTENCE_REBUILD_REQUIRED=NO"
  echo "ATLAS_PREEXECUTION_OBSERVABILITY_CORRIDOR=EVIDENCE_SUPPORTED"
  echo "NEXT_ACTION=DEFINE_MINIMUM_NON_AUTHORITATIVE_PREEXECUTION_ATLAS_OBSERVATION_CONTRACT"
fi

echo
echo "===== AUTHORITY BOUNDARY ====="
echo "ATLAS_AUTHORITY=OBSERVATION_ONLY"
echo "MATILDA_AUTHORITY_CHANGE=NO"
echo "GOVERNANCE_AUTHORITY_CHANGE=NO"
echo "EXECUTION_AUTHORITY_CHANGE=NO"
echo "PREEXECUTION_SOURCE_MUTATION=NO"
echo "DATABASE_SCHEMA_CHANGE=NO"
echo "DOGFOOD_CLEANUP=FROZEN"
echo "IMPLEMENTATION=NO"
echo "MITIGATION=NO"

echo
echo "===== WORKTREE ====="
git status --short
