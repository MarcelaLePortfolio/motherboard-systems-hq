#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== REASSESS MATILDA COLLABORATION RUNTIME MILESTONE VALIDATION ==="

REQUIRED_ANCESTOR="38f421ad"

git merge-base --is-ancestor "$REQUIRED_ANCESTOR" HEAD || {
  echo "STOP: recovery checkpoint $REQUIRED_ANCESTOR is not an ancestor of HEAD."
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
echo "=== VERIFY REASSESSMENT-ONLY SURFACE ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/reassess-matilda-collaboration-runtime-milestone-validation\.sh$|^ M scripts/reassess-matilda-collaboration-runtime-milestone-validation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "REASSESSMENT_ONLY_SURFACE_CONFIRMED"

echo
echo "=== VERIFY RECOVERY CHECKPOINT ==="
grep -nE \
  'FAILED_HYPOTHESIS=MILESTONE_CLOSURE_VALIDATION_SCRIPT_ASSUMPTIONS|FAILED_ATTEMPTS=3|RECOVERY_CHECKPOINT=1a3fb8d7|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MILESTONE_VALIDATION=NOT_YET_COMPLETE|NEXT_ACTION=REASSESS_MILESTONE_VALIDATION_FROM_STABLE_CHECKPOINT_USING_DIFFERENT_APPROACH' \
  scripts/recover-from-milestone-validation-hypothesis.sh

echo
echo "=== VERIFY FOUR PHASE CLOSURE COMMITS ==="
for commit in \
  3d61e635 \
  c0934a3b \
  3320b0ed \
  1a3fb8d7
do
  git merge-base --is-ancestor "$commit" HEAD || {
    echo "STOP: required phase closure commit $commit is not an ancestor of HEAD."
    exit 2
  }
  git show -s --format='%h %s' "$commit"
done

echo "FOUR_PHASE_CLOSURE_LINEAGE_CONFIRMED"

echo
echo "=== VERIFY PHASE 4 DECLARED MILESTONE STATE ==="
grep -nE \
  'PHASE_4_COLLABORATION_GOVERNANCE_COMPLETE|PHASE_4_COLLABORATION_GOVERNANCE_STATUS=CLOSED|PHASE_4_KNOWN_BLOCKING_CAPABILITY_GAPS=NONE|PHASE_1_RESPONSE_COMPOSITION_REMAINS_CLOSED|PHASE_2_INVESTIGATION_LIFECYCLE_REMAINS_CLOSED|PHASE_3_ATTENTION_MANAGEMENT_REMAINS_CLOSED|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE|NEXT_ACTION=VALIDATE_MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE' \
  scripts/close-phase-4-collaboration-governance.sh

echo
echo "=== VERIFY PERMANENT RESPONSE / LIFECYCLE GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY ACTUAL LIFECYCLE CONTRACT TEST ONLY ==="
if [[ -x "./node_modules/.bin/tsx" ]]; then
  ./node_modules/.bin/tsx --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
elif command -v tsx >/dev/null 2>&1; then
  tsx --test scripts/utils/ollamaChat.investigation-lifecycle-contract.test.ts
else
  echo "STOP: repository TypeScript runner unavailable."
  exit 2
fi

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED SINCE PHASE 4 CLOSURE ==="
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
  echo "STOP: production runtime differs from the Phase 4 closure checkpoint."
  git diff 1a3fb8d7 -- "${runtime_files[@]}"
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED_SINCE_PHASE_4_CLOSURE"

echo
echo "=== VERIFY CLOSURE SCRIPTS REMAIN AUTHORITATIVE EVIDENCE ==="
for script in \
  scripts/close-phase-4-collaboration-governance.sh
do
  test -f "$script" || {
    echo "STOP: required closure evidence script missing: $script"
    exit 2
  }
done

echo "CLOSURE_EVIDENCE_PRESENT"

echo
echo "=== REASSESSMENT ==="
cat <<'ASSESSMENT'

Milestone validation reassessment:

1. The prior validation hypothesis failed because it attempted to prove milestone
   closure through speculative textual assertions and nonexistent test surfaces.

2. That hypothesis was reverted after three failed attempts.

3. A different validation strategy is now used.

4. The new strategy validates only evidence already established and supported by
   the repository:

   - Phase 1 closure commit exists in current lineage.
   - Phase 2 closure commit exists in current lineage.
   - Phase 3 closure commit exists in current lineage.
   - Phase 4 closure commit exists in current lineage.
   - Phase 4 closure explicitly records the four-phase milestone as complete.
   - The permanent Ollama response / Investigation Lifecycle guard passes.
   - The actual repository Investigation Lifecycle contract test passes.
   - Production runtime has not changed since Phase 4 closure.

5. This reassessment intentionally does not infer additional runtime properties
   through brittle grep counts or invented tests.

6. No implementation change is required or authorized by this reassessment.

7. The next decision is whether this bounded evidence is sufficient to classify
   the four-phase milestone closure as validated and ready for protection.

ASSESSMENT

echo
echo "MILESTONE_VALIDATION_REASSESSMENT_COMPLETE"
echo "VALIDATION_STRATEGY=LINEAGE_PLUS_EXISTING_GUARDS_PLUS_ACTUAL_TEST"
echo "SPECULATIVE_TEXTUAL_CALL_COUNT_ASSERTIONS=REMOVED"
echo "INVENTED_TEST_SURFACES=REMOVED"
echo "FOUR_PHASE_CLOSURE_LINEAGE=CONFIRMED"
echo "PHASE_4_DECLARED_MILESTONE_STATE=COMPLETE"
echo "OLLAMA_RESPONSE_AND_LIFECYCLE_GUARD=PASS"
echo "ACTUAL_INVESTIGATION_LIFECYCLE_CONTRACT_TEST=PASS"
echo "PRODUCTION_RUNTIME_SINCE_PHASE_4_CLOSURE=UNCHANGED"
echo "IMPLEMENTATION_REQUIRED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_REASSESSED_MATILDA_COLLABORATION_RUNTIME_MILESTONE_VALIDATION"

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED DURING REASSESSMENT ==="
if ! git diff --quiet -- "${runtime_files[@]}"; then
  echo "STOP: production runtime changed during milestone validation reassessment."
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED_DURING_REASSESSMENT"

echo
echo "=== VERIFY REASSESSMENT-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/reassess-matilda-collaboration-runtime-milestone-validation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside reassessment scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "REASSESSMENT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/reassess-matilda-collaboration-runtime-milestone-validation.sh
git diff --cached --check
git commit -m "Reassess Matilda Collaboration Runtime milestone validation"
git push
