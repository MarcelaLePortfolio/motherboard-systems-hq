#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

STABLE_CHECKPOINT="1a3fb8d7"
EXPECTED_HEAD="58218153"

echo "=== RECOVER FROM FAILED MILESTONE VALIDATION HYPOTHESIS ==="

echo
echo "=== BASELINE ==="
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "ORIGIN: $(git rev-parse --short=8 origin/feature/support-source-references-runtime)"
git status --short

current_head="$(git rev-parse --short=8 HEAD)"

if [[ "$current_head" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: expected HEAD $EXPECTED_HEAD before recovery, found $current_head."
  exit 2
fi

git merge-base --is-ancestor "$STABLE_CHECKPOINT" HEAD || {
  echo "STOP: stable checkpoint $STABLE_CHECKPOINT is not an ancestor of HEAD."
  exit 2
}

echo
echo "=== VERIFY ONLY KNOWN UNCOMMITTED VALIDATION CHANGE EXISTS ==="
unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-matilda-collaboration-runtime-milestone-closure\.sh$|^\?\? scripts/recover-from-milestone-validation-hypothesis\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "KNOWN_RECOVERY_SURFACE_CONFIRMED"

echo
echo "=== DOCUMENT FAILED HYPOTHESIS LINEAGE ==="
git log --oneline --reverse "${STABLE_CHECKPOINT}..HEAD"

echo
echo "=== DISCARD UNCOMMITTED THIRD-ATTEMPT VALIDATION EDIT ==="
git restore scripts/validate-matilda-collaboration-runtime-milestone-closure.sh

echo
echo "=== REVERT VALIDATION-HYPOTHESIS COMMITS ==="
git revert --no-commit "${STABLE_CHECKPOINT}..HEAD"

echo
echo "=== VERIFY RECOVERY DIFF ==="
git status --short
git diff --check

echo
echo "=== VERIFY PHASE 4 CLOSURE REMAINS PRESENT ==="
grep -nE \
  'PHASE_4_COLLABORATION_GOVERNANCE_COMPLETE|PHASE_4_COLLABORATION_GOVERNANCE_STATUS=CLOSED|PHASE_4_COLLABORATION_GOVERNANCE=CLOSED|MATILDA_COLLABORATION_RUNTIME_FOUR_PHASE_MILESTONE=COMPLETE|NEXT_ACTION=VALIDATE_MATILDA_COLLABORATION_RUNTIME_MILESTONE_CLOSURE' \
  scripts/close-phase-4-collaboration-governance.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME MATCHES STABLE CHECKPOINT ==="
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

if ! git diff --quiet "$STABLE_CHECKPOINT" -- "${runtime_files[@]}"; then
  echo "STOP: production runtime differs from stable checkpoint $STABLE_CHECKPOINT."
  git diff "$STABLE_CHECKPOINT" -- "${runtime_files[@]}"
  git revert --abort 2>/dev/null || true
  exit 2
fi

echo "PRODUCTION_RUNTIME_MATCHES_STABLE_CHECKPOINT"

echo
echo "=== RECOVERY CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=MILESTONE_CLOSURE_VALIDATION_SCRIPT_ASSUMPTIONS"
echo "FAILED_ATTEMPTS=3"
echo "FAILED_ATTEMPT_1=RAW_NODE_TYPESCRIPT_MODULE_RESOLUTION"
echo "FAILED_ATTEMPT_2=NONEXISTENT_ASSUMED_TEST_FILES"
echo "FAILED_ATTEMPT_3=INVALID_ASSUMPTION_ABOUT_IEL_WRITE_CALL_TEXTUAL_COUNT"
echo "RECOVERY_CHECKPOINT=$STABLE_CHECKPOINT"
echo "PHASE_4_COLLABORATION_GOVERNANCE=CLOSED"
echo "PRODUCTION_RUNTIME=UNCHANGED_FROM_STABLE_CHECKPOINT"
echo "MILESTONE_VALIDATION=NOT_YET_COMPLETE"
echo "DR_TIME=NO"
echo "NEXT_ACTION=REASSESS_MILESTONE_VALIDATION_FROM_STABLE_CHECKPOINT_USING_DIFFERENT_APPROACH"

echo
echo "=== COMMIT RECOVERY ==="
git add -A
git diff --cached --check
git commit -m "Revert failed milestone validation hypothesis"
git push

echo
echo "=== FINAL RECOVERY STATE ==="
echo "HEAD: $(git rev-parse --short=8 HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "ORIGIN: $(git rev-parse --short=8 origin/feature/support-source-references-runtime)"
git status --short
