#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RERUN INVESTIGATION LIFECYCLE TYPED IEL ADAPTER VALIDATION ==="

REQUIRED_ANCESTOR="bf021c71"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: stale-test reconciliation checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY EXPECTED UNCOMMITTED IMPLEMENTATION SURFACE ==="
required_changed=(
  "db/matilda-interpretation-runtime.ts"
  "server/matilda-chat-workflow.ts"
  "scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport.sh"
  "scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts"
)

for path in "${required_changed[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "STOP: expected implementation artifact missing: $path"
    exit 2
  fi
done

unexpected="$(
  git status --porcelain |
  sed -E 's/^.. //' |
  grep -vE '^db/matilda-interpretation-runtime\.ts$|^server/matilda-chat-workflow\.ts$|^scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport\.sh$|^scripts/validate-investigation-lifecycle-typed-iel-workflow-transport\.test\.ts$|^scripts/rerun-investigation-lifecycle-typed-iel-adapter-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_IMPLEMENTATION_SURFACE_CONFIRMED"

echo
echo "=== VERIFY TRANSPORT BOUNDARY CLASSIFICATION ==="
grep -nE \
  'INVESTIGATION_LIFECYCLE_TRANSPORT_BOUNDARY=IEL_OWNS_PERSISTENCE_SERIALIZATION|INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_IMPLEMENTATION_READY' \
  scripts/classify-investigation-lifecycle-workflow-to-iel-transport-boundary.sh

echo
echo "=== VERIFY IEL TYPED INPUT ==="
grep -n -A12 -B8 \
  'investigation_lifecycle?: MatildaInvestigationLifecycleArtifact | null' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY IEL-OWNED SERIALIZATION ==="
grep -n -A14 -B8 \
  'investigation_lifecycle_json:' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY WORKFLOW DIRECT TRANSPORT ==="
grep -n -A12 -B12 \
  'investigation_lifecycle:' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY WORKFLOW DOES NOT OWN JSON REPRESENTATION ==="
if grep -q 'investigation_lifecycle_json' server/matilda-chat-workflow.ts; then
  echo "STOP: workflow references raw lifecycle JSON storage representation."
  grep -n 'investigation_lifecycle_json' server/matilda-chat-workflow.ts
  exit 2
fi

if grep -E \
  'JSON\.stringify\([^)]*investigationLifecycle|JSON\.stringify\([^)]*investigation_lifecycle' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: workflow serializes Investigation Lifecycle."
  exit 2
fi

echo "WORKFLOW_DIRECT_TYPED_TRANSPORT_CONFIRMED"

echo
echo "=== VERIFY WORKFLOW DOES NOT INSPECT SEMANTIC FIELDS ==="
workflow_diff="$(
  git diff -- server/matilda-chat-workflow.ts
)"

if printf '%s\n' "$workflow_diff" |
  grep -E '^\+.*(investigationIdentity|governingQuestion|lifecycleEvent|lifecycleDetermination)'
then
  echo "STOP: workflow inspects Investigation Lifecycle semantic fields."
  exit 2
fi

echo "MATILDA_SEMANTIC_AUTHORSHIP_PRESERVED"

echo
echo "=== TARGETED TYPED TRANSPORT CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== RECONCILED IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== INVESTIGATION LIFECYCLE RESPONSE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== LINEAGE / CONTEXT REGRESSION ==="
npx tsx --test db/matilda-conversation-lineage.test.ts
npx tsx --test server/matilda-interpretation-lifecycle-provider.test.ts
npx tsx --test server/matilda-conversation-context-runtime.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ONE OLLAMA INVOCATION ==="
ollama_fetch_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

echo "OLLAMA_FETCH_REFERENCE_COUNT=$ollama_fetch_count"

if [[ "$ollama_fetch_count" -ne 1 ]]; then
  echo "STOP: expected exactly one Ollama fetch invocation seam."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_PRESERVED"

echo
echo "=== VERIFY ONE IEL WRITE ==="
iel_write_count="$(
  grep -c 'createInterpretationEvidenceLedgerEntry({' \
    server/matilda-chat-workflow.ts ||
  true
)"

echo "IEL_WRITE_COUNT=$iel_write_count"

if [[ "$iel_write_count" -ne 1 ]]; then
  echo "STOP: expected exactly one IEL write per workflow."
  exit 2
fi

echo "ONE_IEL_WRITE_PRESERVED"

echo
echo "=== VERIFY CONVERSATION TURN / CONTEXT RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  db/matilda-conversation-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: deferred runtime surface changed."
  git diff -- \
    db/matilda-conversation-runtime.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "DEFERRED_RUNTIME_SURFACES_UNCHANGED"

echo
echo "=== VERIFY NO SCHEMA CHANGE IN THIS UNIT ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*(ALTER TABLE|ADD COLUMN|CREATE TABLE)' |
  grep -q 'investigation'
then
  echo "STOP: this transport unit introduced an unauthorized lifecycle schema change."
  exit 2
fi

echo "DATABASE_SCHEMA_UNCHANGED"

echo
echo "=== VERIFY NO HISTORICAL BACKFILL ==="
if git diff -- db/matilda-interpretation-runtime.ts |
  grep -E '^\+.*UPDATE .*matilda_interpretation_evidence_ledger' |
  grep -q 'investigation'
then
  echo "STOP: lifecycle historical backfill was introduced."
  exit 2
fi

echo "HISTORICAL_ROWS_REMAIN_NULL_NO_BACKFILL"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "INVESTIGATION_LIFECYCLE_TYPED_IEL_ADAPTER_VALIDATED"
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_VALIDATED"
echo "WORKFLOW_ROLE=DIRECT_TYPED_ARTIFACT_TRANSPORT"
echo "IEL_ROLE=DETERMINISTIC_PERSISTENCE_SERIALIZATION"
echo "NULL_LIFECYCLE=SQL_NULL"
echo "DATABASE_SCHEMA_CHANGE=NONE"
echo "HISTORICAL_BACKFILL=NONE"
echo "CONVERSATION_TURN_PERSISTENCE_UNCHANGED"
echo "CONVERSATION_CONTEXT_RUNTIME_UNCHANGED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "CROSS_TURN_TRANSITION_VALIDATION=DEFERRED"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "ONE_IEL_WRITE_PRESERVED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "NEXT_ACTION=CLASSIFY_INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_IMPLEMENTATION"

git add \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  scripts/implement-investigation-lifecycle-typed-iel-adapter-and-workflow-transport.sh \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts \
  scripts/rerun-investigation-lifecycle-typed-iel-adapter-validation.sh

git diff --cached --check
git commit -m "Implement Investigation Lifecycle workflow transport"
git push
