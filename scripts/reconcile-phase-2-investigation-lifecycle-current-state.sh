#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== RECONCILE PHASE 2 — INVESTIGATION LIFECYCLE CURRENT STATE ==="

REQUIRED_ANCESTOR="3d61e635"

if ! git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD; then
  echo "STOP: HEAD does not contain confirmed Phase 1 closure checkpoint $REQUIRED_ANCESTOR."
  exit 2
fi

echo
echo "=== VERIFY AUTHORIZED WORKING-TREE SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reconcile-phase-2-investigation-lifecycle-current-state\.sh$|^ M scripts/reconcile-phase-2-investigation-lifecycle-current-state\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "AUTHORIZED_RECONCILIATION_SCRIPT_ONLY"

cat <<'FINDINGS'
Phase transition:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE

Next canonical phase:

PHASE_2_INVESTIGATION_LIFECYCLE

Current unit:

RECONCILE_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE

Mode:

COLLABORATION / INVESTIGATION ONLY

Purpose:

Establish the actual current repository capability state for Investigation
Lifecycle before defining or implementing any Phase 2 runtime corridor.

Questions to resolve:

1. What Investigation Lifecycle behavior is defined by current Matilda
   Collaboration Mode V3 methodology and governance evidence?

2. What repository/runtime capabilities already contribute to Investigation
   Lifecycle behavior?

3. Which capabilities are:
   - fully implemented;
   - implemented but not surfaced;
   - characterized but not implemented;
   - absent / not verified?

4. Does a dedicated Investigation Lifecycle runtime already exist?

5. Are investigation state transitions represented anywhere in:
   - workflow;
   - conversation context;
   - interpretation lifecycle;
   - authority evaluation;
   - contamination evaluation;
   - history selection;
   - Living Draft;
   - governance documentation?

6. Is there an existing runtime concept for:
   - opening an investigation;
   - preserving an active question;
   - tracking evidence gathered;
   - recording uncertainty;
   - detecting resolution;
   - closing an investigation;
   - carrying unresolved investigation state forward?

7. Which existing capabilities are supporting primitives rather than Phase 2
   ownership?

8. What is the smallest first Phase 2 corridor supported by evidence?

9. What would its ownership boundary be?

10. What deterministic validation path already exists or can be safely added?

11. What rollback path preserves the Phase 1 stable base?

12. Is implementation actually required, or does repository evidence show that
    some Phase 2 capability is already present?

Required output classification:

Exactly one of:

PHASE_2_INVESTIGATION_LIFECYCLE_FULLY_IMPLEMENTED
PHASE_2_INVESTIGATION_LIFECYCLE_PARTIALLY_IMPLEMENTED
PHASE_2_INVESTIGATION_LIFECYCLE_CHARACTERIZED_ONLY
PHASE_2_INVESTIGATION_LIFECYCLE_NOT_VERIFIED

Also identify:

FIRST_PHASE_2_CORRIDOR=<name or NOT_YET_DETERMINED>

Do not implement.

Do not modify runtime.

Do not modify prompts.

Do not modify Conversation Context.

Do not modify interpretation lifecycle behavior.

Do not modify history selection.

Do not modify Evidence Composition.

Do not reopen Phase 1.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into Phase 2.

Do not create a second semantic author.

Do not add another model invocation.

Preserve:

one user message
-> one workflow
-> one Ollama invocation
-> one IEL entry
-> one conversation turn
-> one Living Draft update.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== PHASE 2 / INVESTIGATION LIFECYCLE REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -Ei \
  'Investigation Lifecycle|investigation lifecycle|investigation state|active investigation|open investigation|close investigation|unresolved investigation|resolution state|evidence gathered|active question|uncertainty' \
  docs scripts server routes db 2>/dev/null || true

echo
echo "=== COLLABORATION MODE V3 REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -Ei \
  'Collaboration Mode V3|Candidate V3|Investigation Lifecycle|Attention Management|Response Composition|Governance' \
  docs scripts 2>/dev/null || true

echo
echo "=== INTERPRETATION LIFECYCLE CAPABILITIES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -Ei \
  'InterpretationLifecycle|interpretation lifecycle|lifecycle entry|authority evaluation|contamination evaluation|evaluatedInterpretations|contaminationEvaluations|selectedHistory' \
  server db scripts docs 2>/dev/null || true

echo
echo "=== CONVERSATION CONTEXT RUNTIME ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -E \
  'MatildaConversationContext|selectedHistory|evaluatedInterpretations|contaminationEvaluations|projectContextExcerpts|projectContextWarning' \
  server db scripts 2>/dev/null || true

echo
echo "=== WORKFLOW OWNERSHIP ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -Ei \
  'matilda-chat-workflow|durableInterpretation|persist.*interpretation|conversation turn|Living Draft|living draft' \
  server db routes scripts 2>/dev/null || true

echo
echo "=== INVESTIGATION-LIKE STATE TYPES / SCHEMAS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='reconcile-phase-2-investigation-lifecycle-current-state.sh' \
  -Ei \
  'status.*open|status.*closed|resolved|unresolved|pending question|active question|investigation|evidence state|resolution' \
  server db routes scripts 2>/dev/null || true

echo
echo "=== CURRENT V3 GOVERNANCE / LINEAGE DOCUMENTS ==="
find docs -type f \
  \( -iname '*V3*' -o -iname '*COLLABORATION*' -o -iname '*INVESTIGATION*' \) \
  -print 2>/dev/null | sort

echo
echo "=== PHASE 1 CLOSURE CONFIRMATION ==="
grep -n \
  'PHASE_1_RESPONSE_COMPOSITION_COMPLETE' \
  scripts/reclassify-phase-1-response-composition-after-evidence-closure.sh

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during Phase 2 reconciliation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reconcile-phase-2-investigation-lifecycle-current-state\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside Phase 2 reconciliation-only scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "PHASE_2_RECONCILIATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "PHASE_2_INVESTIGATION_LIFECYCLE_RECONCILIATION_EVIDENCE_COLLECTED"
echo "PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED"
echo "DEFERRED_CORRIDOR=CONVERSATION_ENGINE_GENERATION_STABILITY"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_PHASE_2_INVESTIGATION_LIFECYCLE_CURRENT_STATE"

git add scripts/reconcile-phase-2-investigation-lifecycle-current-state.sh
git commit -m "Reconcile Phase 2 Investigation Lifecycle current state"
git push
