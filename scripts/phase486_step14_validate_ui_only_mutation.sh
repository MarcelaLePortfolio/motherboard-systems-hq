#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step14_ui_only_mutation_validation.txt"

{
  echo "PHASE 486 — STEP 14"
  echo "UI-ONLY MUTATION VALIDATION"
  echo
  echo "OBJECTIVE"
  echo
  echo "Validate that Step 13 remained a single-boundary UI mutation"
  echo "and did not introduce backend file changes."
  echo
  echo "COMMIT UNDER VALIDATION"
  git rev-parse HEAD
  echo
  git log -1 --oneline
  echo
  echo "FILES CHANGED IN LAST COMMIT"
  git diff --name-only HEAD~1 HEAD
  echo
  echo "FULL LAST-COMMIT STAT"
  git show --stat --oneline --no-patch HEAD
  git show --stat --format=medium HEAD
  echo
  echo "BACKEND-SCOPE CHANGE CHECK"
  CHANGED_FILES="$(git diff --name-only HEAD~1 HEAD)"
  if printf '%s\n' "$CHANGED_FILES" | grep -qvE '^app/demo-runtime/page\.tsx$'; then
    echo "RESULT: FAIL"
    echo "Reason: last commit changed files outside the approved UI host."
  else
    echo "RESULT: PASS"
    echo "Reason: last commit changed only app/demo-runtime/page.tsx."
  fi
  echo
  echo "TARGET FILE DIFF"
  git diff HEAD~1 HEAD -- app/demo-runtime/page.tsx
  echo
  echo "GOVERNANCE PANEL SIGNAL CHECK"
  grep -nE 'Governance Trace|Approval present|Governance evaluated|Authority ordering valid|Rule-level trace|NO DATA' app/demo-runtime/page.tsx || true
  echo
  echo "PROHIBITED TRACE FABRICATION CHECK"
  if git diff HEAD~1 HEAD -- app/demo-runtime/page.tsx | grep -qE 'ruleId|evaluationResult|rules\['; then
    echo "RESULT: FAIL"
    echo "Reason: fabricated rule-level trace signals detected in UI diff."
  else
    echo "RESULT: PASS"
    echo "Reason: no fabricated rule-level trace fields introduced."
  fi
  echo
  echo "VALIDATION CONCLUSION"
  echo
  echo "UI-only mutation validation complete."
  echo "If both checks above are PASS, Step 13 preserved backend freeze."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
