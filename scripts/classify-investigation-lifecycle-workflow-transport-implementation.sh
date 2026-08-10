#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY INVESTIGATION LIFECYCLE WORKFLOW TRANSPORT IMPLEMENTATION ==="

REQUIRED_ANCESTOR="16f1d16f"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: validated workflow-transport checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-investigation-lifecycle-workflow-transport-implementation\.sh$|^ M scripts/classify-investigation-lifecycle-workflow-transport-implementation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY TYPED IEL ADAPTER ==="
grep -n \
  'investigation_lifecycle?: MatildaInvestigationLifecycleArtifact | null' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY IEL-OWNED SERIALIZATION ==="
grep -n -A8 \
  'investigation_lifecycle_json:' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY WORKFLOW DIRECT TRANSPORT ==="
grep -n -A4 -B4 \
  'investigation_lifecycle:' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY WORKFLOW STORAGE INDEPENDENCE ==="
if grep -q 'investigation_lifecycle_json' server/matilda-chat-workflow.ts; then
  echo "STOP: workflow references IEL lifecycle storage representation."
  exit 2
fi

echo "WORKFLOW_STORAGE_INDEPENDENCE_CONFIRMED"

echo
echo "=== TARGETED TRANSPORT CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-typed-iel-workflow-transport.test.ts

echo
echo "=== IEL PERSISTENCE CONTRACT ==="
npx tsx --test \
  scripts/validate-investigation-lifecycle-iel-bounded-json-persistence.test.ts

echo
echo "=== STRUCTURED RESPONSE CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ONE INVOCATION AND ONE IEL WRITE ==="
ollama_fetch_count="$(
  grep -c 'fetch(' scripts/utils/ollamaChat.ts ||
  true
)"

iel_write_count="$(
  grep -c 'createInterpretationEvidenceLedgerEntry({' \
    server/matilda-chat-workflow.ts ||
  true
)"

echo "OLLAMA_FETCH_REFERENCE_COUNT=$ollama_fetch_count"
echo "IEL_WRITE_COUNT=$iel_write_count"

[[ "$ollama_fetch_count" -eq 1 ]] || {
  echo "STOP: expected exactly one Ollama invocation seam."
  exit 2
}

[[ "$iel_write_count" -eq 1 ]] || {
  echo "STOP: expected exactly one IEL write seam."
  exit 2
}

echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "ONE_IEL_WRITE_PRESERVED"

echo
echo "=== VERIFY CLASSIFICATION DID NOT MODIFY PRODUCTION RUNTIME ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-conversation-context-runtime.ts
then
  echo "STOP: production runtime changed during classification."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-conversation-runtime.ts \
    server/matilda-conversation-context-runtime.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

cat <<'FINDINGS'

Classification:

INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_IMPLEMENTED_AND_VALIDATED

Repository-supported determination:

1. Matilda authors the bounded Investigation Lifecycle semantic artifact.

2. The production workflow transports that artifact directly without inspecting
   or transforming its semantic fields.

3. The Interpretation Evidence Ledger accepts the typed artifact at its API
   boundary.

4. IEL owns deterministic conversion to the existing
   investigation_lifecycle_json persistence representation.

5. Null Investigation Lifecycle state persists as SQL NULL.

6. No lifecycle database schema change was required by this transport unit.

7. No historical lifecycle backfill was introduced.

8. Conversation-turn persistence remains unchanged.

9. Conversation Context Runtime remains unchanged.

10. The existing one-Ollama-invocation architecture remains preserved.

11. The existing one-IEL-write workflow architecture remains preserved.

12. Therefore the current-turn lifecycle path is complete:

    Matilda semantic authorship
    ->
    validated structured response
    ->
    workflow direct typed transport
    ->
    IEL deterministic persistence serialization
    ->
    investigation_lifecycle_json

13. Current-turn transport and persistence must not be reopened without
    contradictory repository evidence.

14. This implementation does not establish cross-turn lifecycle continuity.

15. It does not establish reconstruction of persisted lifecycle JSON into
    semantic lifecycle state for later turns.

16. It does not establish cross-turn lifecycle transition validation.

17. Those capabilities remain separate from the completed current-turn path.

Classification:

CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_COMPLETE

Deferred:

INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION

INVESTIGATION_LIFECYCLE_CROSS_TURN_TRANSITION_VALIDATION

Next canonical unit:

INVESTIGATE_INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_CURRENT_STATE

The next unit is investigation only.

Before implementation, determine:

- whether investigation_lifecycle_json is currently read anywhere;
- whether existing IEL read models expose it;
- whether the lifecycle provider consumes it;
- whether Conversation Context Runtime carries it;
- whether selectedHistory carries sufficient lifecycle identity;
- where reconstruction ownership belongs;
- whether persisted lifecycle state should enter semantic generation through
  existing context composition or a dedicated lifecycle seam;
- whether continuity can be added without another model invocation;
- the smallest safe implementation surface;
- the regression and rollback paths.

Do not implement continuity reconstruction during this classification.

Do not implement transition validation.

Do not add another lifecycle persistence representation.

Do not alter conversation-turn persistence.

Do not alter Living Draft behavior.

Do not alter Phase 1 Response Composition.

Do not change generation policy.

Do not add retries.

Do not add another model invocation.

Do not reopen Phase 1.

Preserve:

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update

Preserve Matilda as Interpretation Authority.

FINDINGS

echo
echo "INVESTIGATION_LIFECYCLE_WORKFLOW_TRANSPORT_IMPLEMENTED_AND_VALIDATED"
echo "CURRENT_TURN_INVESTIGATION_LIFECYCLE_PATH_COMPLETE"
echo "MATILDA_ROLE=SEMANTIC_AUTHORSHIP"
echo "WORKFLOW_ROLE=DIRECT_TYPED_ARTIFACT_TRANSPORT"
echo "IEL_ROLE=DETERMINISTIC_PERSISTENCE_SERIALIZATION"
echo "NULL_LIFECYCLE=SQL_NULL"
echo "ONE_OLLAMA_INVOCATION_PRESERVED"
echo "ONE_IEL_WRITE_PRESERVED"
echo "CONTINUITY_RECONSTRUCTION=DEFERRED"
echo "CROSS_TURN_TRANSITION_VALIDATION=DEFERRED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=INVESTIGATE_INVESTIGATION_LIFECYCLE_CONTINUITY_RECONSTRUCTION_CURRENT_STATE"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-investigation-lifecycle-workflow-transport-implementation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  scripts/classify-investigation-lifecycle-workflow-transport-implementation.sh

git diff --cached --check
git commit -m "Classify Investigation Lifecycle workflow transport implementation"
git push
