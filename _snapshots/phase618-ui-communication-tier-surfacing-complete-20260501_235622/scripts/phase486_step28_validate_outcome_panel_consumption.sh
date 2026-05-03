#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase486_step28_outcome_panel_consumption_validation.txt"

{
  echo "PHASE 486 — STEP 28"
  echo "OUTCOME PANEL CONSUMPTION VALIDATION"
  echo
  echo "OBJECTIVE"
  echo
  echo "Validate that Step 27 remained a UI-only mutation and that the"
  echo "Outcome panel refinement used only existing report fields."
  echo
  echo "COMMIT UNDER VALIDATION"
  git rev-parse HEAD
  git log -1 --oneline
  echo
  echo "FILES CHANGED IN LAST COMMIT"
  git diff --name-only HEAD~1 HEAD
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
  echo "OUTCOME PANEL SIGNAL CHECK"
  grep -nE 'Outcome</h3>|Final result|report\.finalDemoResult|taskOutcomes' app/demo-runtime/page.tsx || true
  echo
  echo "NO-TRANSFORMATION CHECK"
  if git diff HEAD~1 HEAD -- app/demo-runtime/page.tsx | grep -qE 'sort\(|filter\(|reduce\(|Set\(|new Set|join\(|derive|computed|summary|count'; then
    echo "RESULT: FAIL"
    echo "Reason: transformation signal detected in Outcome panel diff."
  else
    echo "RESULT: PASS"
    echo "Reason: Outcome panel refinement uses direct existing values only."
  fi
  echo
  echo "TYPECHECK"
  if [ -f "pnpm-lock.yaml" ]; then
    pnpm exec tsc --noEmit
  elif [ -f "package-lock.json" ]; then
    npx tsc --noEmit
  elif [ -f "yarn.lock" ]; then
    yarn tsc --noEmit
  else
    echo "FAIL: no supported package manager lockfile detected"
    exit 1
  fi
  echo
  echo "POST-VALIDATION STATUS"
  git status --short
  echo
  echo "VALIDATION CONCLUSION"
  echo "If all checks above are PASS, Step 27 preserved backend freeze and passive consumption rules."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
