#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY REASSESSED MATILDA COLLABORATION RUNTIME MILESTONE VALIDATION ==="

REQUIRED_ANCESTOR="3c688936"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: reassessment checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
echo "=== VERIFY CLASSIFICATION-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-reassessed-matilda-collaboration-runtime-milestone-validation\.sh$|^ M scripts/classify-reassessed-matilda-collaboration-runtime-milestone-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "CLASSIFICATION_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY REASSESSMENT RESULT ==="
grep -nE \
  'MILESTONE_VALIDATION_REASSESSMENT_COMPLETE|VALIDATION_STRATEGY=LINEAGE_PLUS_EXISTING_GUARDS_PLUS_ACTUAL_TEST|SPECULATIVE_TEXTUAL_CALL_COUNT_ASSERTIONS=REMOVED|INVENTED_TEST_SURFACES=REMOVED|FOUR_PHASE_CLOSURE_LINEAGE=CONFIRMED|PHASE_4_DECLARED_MILESTONE_STATE=COMPLETE|OLLAMA_RESPONSE_AND_LIFECYCLE_GUARD=PASS|ACTUAL_INVESTIGATION_LIFECYCLE_CONTRACT_TEST=PASS|PRODUCTION_RUNTIME_SINCE_PHASE_4_CLOSURE=UNCHANGED|IMPLEMENTATION_REQUIRED=NO|IMPLEMENTATION_AUTHORIZED=NO|NEXT_ACTION=CLASSIFY_REASSESSED_MATILDA_COLLABORATION_RUNTIME_MILESTONE_VALIDATION' \
  scripts/reassess-matilda-collaboration-runtime-milestone-validation.sh

echo
echo "=== VERIFY FOUR-PHASE CLOSURE LINEAGE ==="
for commit in \
  3d61e635 \
  c0934a3b \
  3320b0ed \
  1a3fb8d7
do
  git merge-base --is-ancestor "$commit" HEAD || {
    echo "STOP: required closure commit $commit is not an ancestor of HEAD."
    exit 2
  }
  git show -s --format='%h %s' "$commit"
done

echo "FOUR_PHASE_CLOSURE_LINEAGE_CONFIRMED"

echo
echo "=== VERIFY PHASE 4 CLOSURE DECLARATION ==="
grep -nE \
  'PHASE_4_COLLABORATION_GOVERNANCE_STATUS=CLOSED|PHASE_4_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE|PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED|PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE' \
  scripts/close-phase-4-collaboration-governance.sh

echo
echo "=== VERIFY PERMANENT CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ACTUAL LIFECYCLE CONTRACT TEST ==="
if [[ -x "./node_modules/.bin/tsx" ]]; then
  ./node_modules/.bin/tsx --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
elif command -v tsx >/dev/null 2>&1; then
  tsx --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
else
  echo "STOP: repository TypeScript runner unavailable."
  exit 2
fi

echo
echo "=== VERIFY PRODUCTION RUNTIME STILL MATCHES PHASE 4 CLOSURE ==="
runtime_files=(
  scripts/utils/ollamaChat.ts
  db/matilda-interpretation-runtime.ts
  db/matilda-conversation-runtime.ts
  server/matilda-chat-workflow.ts
  server/matilda-conversation-context-runtime.ts
  server/matilda-history-selection-runtime.ts
  server/matilda-history-authority-evaluator.ts
  server/matilda-history-contamination-evaluator.ts
)

if ! git diff --quiet 1a3fb8d7 -- "${runtime_files[@]}"; then
  echo "STOP: production runtime differs from Phase 4 closure checkpoint 1a3fb8d7."
  git diff 1a3fb8d7 -- "${runtime_files[@]}"
  exit 2
fi

echo "PRODUCTION_RUNTIME_MATCHES_PHASE_4_CLOSURE"

echo
echo "=== CLASSIFICATION ==="
cat <<'CLASSIFICATION'

Reassessed Matilda Collaboration Runtime milestone validation classification:

1. The original milestone-validation hypothesis was abandoned after three failed
   attempts and was reverted in accordance with the build protocol.

2. The replacement validation strategy is materially different: it relies on
   established closure lineage, permanent repository guards, the actual
   repository-supported Investigation Lifecycle contract test, and runtime
   immutability since Phase 4 closure.

3. Phase 1 — Response Composition is closed.

4. Phase 2 — Investigation Lifecycle is closed.

5. Phase 3 — Attention Management is closed.

6. Phase 4 — Collaboration Governance is closed.

7. Phase 4 closure explicitly records the currently defined four-phase Matilda
   Collaboration Runtime milestone as complete with no known Phase 4 blocking
   capability gap.

8. The permanent Ollama response and Investigation Lifecycle contract guard
   passes.

9. The actual Investigation Lifecycle contract test passes under the
   repository-supported TypeScript runner.

10. Production runtime remains unchanged from the Phase 4 closure checkpoint.

11. No new runtime implementation is required by milestone closure validation.

12. No new runtime implementation is authorized by this classification.

13. The available bounded evidence is sufficient to classify the currently
    defined Matilda Collaboration Runtime four-phase milestone closure as
    validated.

14. No known blocking capability gap remains inside this milestone boundary.

15. Deferred successor concerns remain outside this closure and do not reopen
    the four completed phases unless separately activated through evidence-first
    investigation.

16. The milestone is ready for DR protection.

CLASSIFICATION

echo
echo "REASSESSED_MILESTONE_VALIDATION_CLASSIFIED"
echo "PHASE_1_RESPONSE_COMPOSITION=CLOSED"
echo "PHASE_2_INVESTIGATION_LIFECYCLE=CLOSED"
echo "PHASE_3_ATTENTION_MANAGEMENT=CLOSED"
echo "PHASE_4_COLLABORATION_GOVERNANCE=CLOSED"
echo "MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE"
echo "MILESTONE_CLOSURE_VALIDATION=CONFIRMED"
echo "VALIDATION_EVIDENCE=SUFFICIENT"
echo "KNOWN_BLOCKING_CAPABILITY_GAPS=NONE_WITHIN_CURRENT_MILESTONE"
echo "PRODUCTION_RUNTIME_CHANGE=NONE"
echo "IMPLEMENTATION_REQUIRED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "DR_READINESS=CONFIRMED"
echo "NEXT_ACTION=PROTECT_MATILDA_COLLABORATION_RUNTIME_MILESTONE_WITH_DR"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING CLASSIFICATION ==="
if ! git diff --quiet -- "${runtime_files[@]}"; then
  echo "STOP: production runtime changed during milestone-validation classification."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED_DURING_CLASSIFICATION"

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-reassessed-matilda-collaboration-runtime-milestone-validation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside milestone-validation classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-reassessed-matilda-collaboration-runtime-milestone-validation.sh
git diff --cached --check
git commit -m "Classify Matilda Collaboration Runtime milestone closure"
git push
