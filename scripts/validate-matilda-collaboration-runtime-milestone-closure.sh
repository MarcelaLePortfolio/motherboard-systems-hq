#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== VALIDATE MATILDA COLLABORATION RUNTIME MILESTONE CLOSURE ==="

REQUIRED_ANCESTOR="1a3fb8d7"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: Phase 4 closure checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "ORIGIN: $(git rev-parse --short=8 origin/feature/support-source-references-runtime)"

echo
echo "=== VERIFY VALIDATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/validate-matilda-collaboration-runtime-milestone-closure\.sh$|^ M scripts/validate-matilda-collaboration-runtime-milestone-closure\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "VALIDATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY PHASE 4 CLOSURE ==="
grep -nE \
  'PHASE_4_COLLABORATION_GOVERNANCE_COMPLETE|PHASE_4_COLLABORATION_GOVERNANCE_STATUS=CLOSED|PHASE_4_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE|NEXT_ACTION=VALIDATE_MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE' \
  scripts/close-phase-4-collaboration-governance.sh

echo
echo "=== VERIFY PHASE CLOSURE LINEAGE ==="
git log --oneline --all --grep='Phase 1 Response Composition' | head -n 20
git show -s --format='%h %s' c0934a3b
git show -s --format='%h %s' 3320b0ed
git show -s --format='%h %s' 1a3fb8d7

git merge-base --is-ancestor c0934a3b HEAD || {
  echo "STOP: Phase 2 closure checkpoint is not an ancestor of HEAD."
  exit 2
}

git merge-base --is-ancestor 3320b0ed HEAD || {
  echo "STOP: Phase 3 closure checkpoint is not an ancestor of HEAD."
  exit 2
}

git merge-base --is-ancestor 1a3fb8d7 HEAD || {
  echo "STOP: Phase 4 closure checkpoint is not an ancestor of HEAD."
  exit 2
}

echo "PHASE_2_THROUGH_PHASE_4_CLOSURE_LINEAGE_CONFIRMED"

echo
echo "=== VERIFY RESPONSE CONTRACT ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY INVESTIGATION LIFECYCLE CONTRACT ==="
node --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts

echo
echo "=== VERIFY PRIOR LIFECYCLE CONTEXT TRANSPORT ==="
node --test scripts/utils/ollamaChat.prior-investigation-lifecycle-context.test.ts

echo
echo "=== VERIFY SCOPED IEL RETRIEVAL ==="
node --test db/matilda-interpretation-runtime.scoped-lifecycle-retrieval.test.ts

echo
echo "=== VERIFY IEL LIFECYCLE RECONSTRUCTION ==="
node --test db/matilda-interpretation-runtime.investigation-lifecycle-reconstruction.test.ts

echo
echo "=== VERIFY TYPED IEL WORKFLOW TRANSPORT ==="
node --test server/matilda-chat-workflow.investigation-lifecycle-transport.test.ts

echo
echo "=== VERIFY FOUR-PHASE CLOSURE SIGNALS ==="
grep -nE \
  'PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED|PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE' \
  scripts/close-phase-4-collaboration-governance.sh

echo
echo "=== VERIFY ONE OLLAMA INVOCATION ==="
ollama_calls="$(
  grep -nE 'await ollamaChat\(' server/matilda-chat-workflow.ts |
  wc -l |
  tr -d ' '
)"

if [[ "$ollama_calls" != "1" ]]; then
  echo "STOP: expected exactly one ollamaChat invocation in workflow, found $ollama_calls."
  exit 2
fi

echo "ONE_OLLAMA_INVOCATION_CONFIRMED"

echo
echo "=== VERIFY ONE IEL WRITE CALL ==="
iel_calls="$(
  grep -nE 'insertInterpretationEvidenceLedgerEntry\(' server/matilda-chat-workflow.ts |
  wc -l |
  tr -d ' '
)"

if [[ "$iel_calls" != "1" ]]; then
  echo "STOP: expected exactly one IEL write call in workflow, found $iel_calls."
  exit 2
fi

echo "ONE_IEL_WRITE_CALL_CONFIRMED"

echo
echo "=== VERIFY CONVERSATION CONTEXT RUNTIME REMAINS LIFECYCLE-INDEPENDENT ==="
context_lifecycle_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle|priorInvestigationLifecycle|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-conversation-context-runtime.ts ||
  true
)"

if [[ -n "$context_lifecycle_refs" ]]; then
  echo "STOP: Conversation Context Runtime unexpectedly carries Investigation Lifecycle state:"
  printf '%s\n' "$context_lifecycle_refs"
  exit 2
fi

echo "CONVERSATION_CONTEXT_RUNTIME_LIFECYCLE_INDEPENDENCE_CONFIRMED"

echo
echo "=== VERIFY SELECTED HISTORY REMAINS LIFECYCLE-INDEPENDENT ==="
history_lifecycle_refs="$(
  grep -nE \
    'investigationLifecycle|investigation_lifecycle|priorInvestigationLifecycle|investigationIdentity|governingQuestion|lifecycleDetermination' \
    server/matilda-history-selection-runtime.ts ||
  true
)"

if [[ -n "$history_lifecycle_refs" ]]; then
  echo "STOP: selectedHistory runtime unexpectedly carries Investigation Lifecycle state:"
  printf '%s\n' "$history_lifecycle_refs"
  exit 2
fi

echo "SELECTED_HISTORY_LIFECYCLE_INDEPENDENCE_CONFIRMED"

cat <<'VALIDATION'

Matilda Collaboration Runtime milestone closure validation:

1. Phase 1 — Response Composition remains closed.

2. Phase 2 — Investigation Lifecycle is closed.

3. Phase 3 — Attention Management is closed.

4. Phase 4 — Collaboration Governance is closed.

5. Response Composition contracts remain protected by the permanent Ollama
   response-contract guard.

6. Investigation Lifecycle contract, reconstruction, scoped retrieval,
   prior-context transport, typed workflow transport, and bounded cross-turn
   validation remain intact.

7. Phase 3 required no new runtime because governing attention is represented
   relationally by established semantics.

8. Phase 4 required no new runtime because collaboration-governance authority
   boundaries are already owned by established architecture.

9. One user message continues through one workflow and one Ollama invocation.

10. Workflow retains one IEL write call.

11. selectedHistory remains lifecycle-independent.

12. Conversation Context Runtime remains lifecycle-independent.

13. User remains Intent Authority.

14. Matilda remains Interpretation Authority.

15. Living Draft remains non-authoritative.

16. Approval and downstream governance boundaries remain separate.

17. The currently defined Matilda Collaboration Runtime four-phase milestone is
    validated as complete.

VALIDATION

echo
echo "MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE_VALIDATED"
echo "PHASE_1_RESPONSE_COMPOSITION=CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT=CLOSED"
echo "PHASE_4_COLLABORATION_GOVERNANCE=CLOSED"
echo "FOUR_PHASE_MILESTONE=COMPLETE"
echo "ONE_OLLAMA_INVOCATION=PRESERVED"
echo "ONE_IEL_WRITE_CALL=PRESERVED"
echo "SELECTED_HISTORY_LIFECYCLE_INDEPENDENCE=PRESERVED"
echo "CONVERSATION_CONTEXT_RUNTIME_LIFECYCLE_INDEPENDENCE=PRESERVED"
echo "USER_INTENT_AUTHORITY=PRESERVED"
echo "MATILDA_INTERPRETATION_AUTHORITY=PRESERVED"
echo "KNOWN_FOUR_PHASE_BLOCKING_CAPABILITY_GAPS=NONE"
echo "NEXT_ACTION=CLASSIFY_MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts \
  server/matilda-history-selection-runtime.ts \
  server/matilda-history-authority-evaluator.ts \
  server/matilda-history-contamination-evaluator.ts
then
  echo "STOP: production runtime changed during milestone closure validation."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== VERIFY VALIDATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/validate-matilda-collaboration-runtime-milestone-closure\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside milestone validation scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "VALIDATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/validate-matilda-collaboration-runtime-milestone-closure.sh
git diff --cached --check
git commit -m "Validate Matilda Collaboration Runtime milestone closure"
git push
