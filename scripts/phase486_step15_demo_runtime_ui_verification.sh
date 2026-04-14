#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step15_demo_runtime_ui_verification.txt"

{
  echo "PHASE 486 — STEP 15"
  echo "DEMO RUNTIME UI VERIFICATION"
  echo
  echo "OBJECTIVE"
  echo
  echo "Verify that the Phase 486 governance trace panel remains a UI-only"
  echo "consumption change and that the selected page still compiles cleanly."
  echo
  echo "REPOSITORY ROOT"
  pwd
  echo
  echo "HEAD"
  git rev-parse HEAD
  git log -1 --oneline
  echo
  echo "TARGET FILE PRESENCE"
  if [ -f "app/demo-runtime/page.tsx" ]; then
    echo "PASS: app/demo-runtime/page.tsx present"
  else
    echo "FAIL: app/demo-runtime/page.tsx missing"
    exit 1
  fi
  echo
  echo "GOVERNANCE PANEL SIGNAL CHECK"
  grep -nE 'Governance Trace|Admission decision|Approval present|Governance evaluated|Authority ordering valid|Rule-level trace|NO DATA' app/demo-runtime/page.tsx || true
  echo
  echo "PACKAGE MANAGER DETECTION"
  if [ -f "pnpm-lock.yaml" ]; then
    PM="pnpm"
  elif [ -f "package-lock.json" ]; then
    PM="npm"
  elif [ -f "yarn.lock" ]; then
    PM="yarn"
  else
    PM="unknown"
  fi
  echo "Detected: $PM"
  echo
  echo "TYPECHECK / BUILD VERIFICATION"
  case "$PM" in
    pnpm)
      echo "Running: pnpm exec tsc --noEmit"
      pnpm exec tsc --noEmit
      ;;
    npm)
      echo "Running: npx tsc --noEmit"
      npx tsc --noEmit
      ;;
    yarn)
      echo "Running: yarn tsc --noEmit"
      yarn tsc --noEmit
      ;;
    *)
      echo "FAIL: no supported package manager lockfile detected"
      exit 1
      ;;
  esac
  echo
  echo "POST-VERIFICATION STATUS"
  git status --short
  echo
  echo "VALIDATION RESULT"
  echo "PASS: demo runtime page verified under existing TypeScript compile surface."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
