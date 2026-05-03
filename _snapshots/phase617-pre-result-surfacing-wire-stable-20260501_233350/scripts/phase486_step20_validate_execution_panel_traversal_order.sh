#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step20_execution_panel_traversal_order_validation.txt"

{
  echo "PHASE 486 — STEP 20"
  echo "EXECUTION PANEL TRAVERSAL ORDER VALIDATION"
  echo
  echo "OBJECTIVE"
  echo
  echo "Validate that Step 19 remained a UI-only mutation and that traversalOrder"
  echo "was surfaced passively without transformation or backend expansion."
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
  echo "TRAVERSAL ORDER SIGNAL CHECK"
  grep -nE 'Traversal order|report\.traversalOrder|NO DATA|Task definitions' app/demo-runtime/page.tsx || true
  echo
  echo "NO-TRANSFORMATION CHECK"
  if git diff HEAD~1 HEAD -- app/demo-runtime/page.tsx | grep -qE 'sort\(|filter\(|reduce\(|Set\(|new Set|map\(\(.*task.*=>.*report\.traversalOrder|join\('; then
    echo "RESULT: FAIL"
    echo "Reason: transformation signal detected in traversalOrder render diff."
  else
    echo "RESULT: PASS"
    echo "Reason: traversalOrder rendered without transformation signals."
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
  echo "If all checks above are PASS, Step 19 preserved backend freeze and passive consumption rules."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
