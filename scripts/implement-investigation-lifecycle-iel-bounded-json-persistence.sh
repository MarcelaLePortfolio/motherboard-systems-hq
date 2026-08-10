#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== IMPLEMENT INVESTIGATION LIFECYCLE IEL BOUNDED JSON PERSISTENCE ==="

REQUIRED_ANCESTOR="460c7dc5"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: required classification checkpoint is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/implement-investigation-lifecycle-iel-bounded-json-persistence\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected pre-existing working-tree changes:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VERIFY CLASSIFIED CONTRACT ==="
grep -n \
  -E 'IEL_REPRESENTATION=IEL_BOUNDED_LIFECYCLE_JSON|SCHEMA_EXTENSION=investigation_lifecycle_json_TEXT_NULL|HISTORICAL_ROWS=NULL_NO_BACKFILL' \
  scripts/classify-investigation-lifecycle-iel-representation.sh

echo
echo "=== VERIFY IMPLEMENTATION SURFACE ==="
test -f db/matilda-interpretation-runtime.ts || {
  echo "STOP: IEL runtime not found."
  exit 2
}

grep -n \
  -E 'CREATE TABLE IF NOT EXISTS matilda_interpretation_evidence_ledger|supersession_status|INSERT INTO matilda_interpretation_evidence_ledger' \
  db/matilda-interpretation-runtime.ts

echo
echo "IMPLEMENTATION_SURFACE_CONFIRMED"
echo "PERSISTENCE_OWNER=IEL"
echo "REPRESENTATION=investigation_lifecycle_json_TEXT_NULL"
echo "HISTORICAL_ROWS=NULL_NO_BACKFILL"
echo "WORKFLOW_CONSUMPTION_NOT_AUTHORIZED"
echo "CONTINUITY_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/implement-investigation-lifecycle-iel-bounded-json-persistence.sh
git diff --cached --check
git commit -m "Add Investigation Lifecycle IEL persistence implementation unit"
git push

echo
echo "IMPLEMENTATION_UNIT_CHECKPOINTED"
echo "NEXT_ACTION=RUN_INVESTIGATION_LIFECYCLE_IEL_PERSISTENCE_IMPLEMENTATION"
