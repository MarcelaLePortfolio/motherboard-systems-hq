#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase471_2_fix_false_positive_classification.txt"
HTML="public/dashboard.html"

mkdir -p docs

{
  echo "PHASE 471.2 — FIX FALSE POSITIVE CLASSIFICATION"
  echo "=============================================="
  echo

  echo "STEP 1 — Show why phase471.1 misclassified"
  echo "The previous check matched the filename inside the neutralization comment."
  echo
  rg -n 'phase457_restore_task_panels\.js' "$HTML" || true
  echo

  echo "STEP 2 — Verify actual script tag absence"
  if rg -q '<script src="/js/phase457_restore_task_panels\.js"></script>' "$HTML"; then
    echo "ACTUAL_SCRIPT_TAG_PRESENT"
  else
    echo "ACTUAL_SCRIPT_TAG_ABSENT"
  fi
  echo

  echo "STEP 3 — Verify neutralization marker presence"
  rg -n 'phase471\.1 temporary neutralization' "$HTML" || true
  echo

  echo "STEP 4 — Corrected classification"
  if rg -q '<script src="/js/phase457_restore_task_panels\.js"></script>' "$HTML"; then
    echo "CLASSIFICATION: SCRIPT_TAG_STILL_PRESENT"
  else
    echo "CLASSIFICATION: TASK_EVENTS_SCRIPT_REMOVED_FOR_REAL"
  fi
  echo

  echo "DECISION TARGET"
  echo "- The phase471.1 result was a false positive."
  echo "- The task-events restore script is removed for real."
  echo "- Next step is browser observation only."
  echo "- Report one of: STABLE_AFTER_REAL_TASK_EVENTS_REMOVAL / STILL_FREEZES / WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
