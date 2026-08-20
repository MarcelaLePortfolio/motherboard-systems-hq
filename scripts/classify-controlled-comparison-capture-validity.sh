#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

CAPTURE="/tmp/matilda-controlled-comparison-output.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=72f42ecf' \
  'ISSUE_RESOLVED=NO' \
  'ACTION=CLASSIFY_CONTROLLED_COMPARISON_CAPTURE_VALIDITY'

printf '\n=== CAPTURE VALIDITY ===\n'
if grep -q "cat > scripts/capture-controlled-comparison-from-clipboard.sh" "$CAPTURE"; then
  printf '%s\n' \
    'CAPTURE_SOURCE=CAPTURE_SCRIPT_TEXT' \
    'CONTROLLED_COMPARISON_RESULT_CAPTURED=NO' \
    'FALSE_POSITIVE_MARKER_MATCH=YES'
else
  printf '%s\n' \
    'CAPTURE_SOURCE=UNKNOWN_OR_TERMINAL_OUTPUT' \
    'FALSE_POSITIVE_MARKER_MATCH=NO'
fi

printf '\n=== REQUIRED ORIGINAL RESULT MARKERS ===\n'
for marker in \
  '=== CONTROLLED RUN 1/10 ===' \
  '=== CONTROLLED RUN 10/10 ===' \
  '=== COMPARISON SUMMARY ===' \
  '=== ACCEPTANCE BOUNDARY ==='
do
  if grep -Fq "$marker" "$CAPTURE"; then
    echo "PRESENT=$marker"
  else
    echo "MISSING=$marker"
  fi
done

printf '\n=== DETERMINATION ===\n'
printf '%s\n' \
  'CONTROLLED_ARM_COMPLETION_ESTABLISHED=NO' \
  'COMPARISON_RESULT_CLASSIFIABLE=NO' \
  'PRODUCTION_CHANGE_AUTHORIZED=NO' \
  'NEW_EXPERIMENT_AUTHORIZED=NO' \
  'NEXT_ACTION=PASTE_ORIGINAL_TTYS168_OUTPUT_DIRECTLY_FROM_CONTROLLED_RUN_1_THROUGH_ACCEPTANCE_BOUNDARY'

printf '\n=== WORKTREE ===\n'
git status --short
