#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase486_step5_ui_surface_inventory.txt"

{
  echo "PHASE 486 — STEP 5"
  echo "UI SURFACE INVENTORY"
  echo
  echo "OBJECTIVE"
  echo
  echo "Identify candidate UI files for governance trace panel implementation"
  echo "without mutating backend logic or contracts."
  echo
  echo "SEARCH ROOT"
  pwd
  echo
  echo "TOP-LEVEL APP/UI DIRECTORIES"
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './.next' -prune -o \
    -path './dist' -prune -o \
    -path './build' -prune -o \
    -type d \( \
      -name app -o \
      -name src -o \
      -name components -o \
      -name ui -o \
      -name dashboard \
    \) -print | sort
  echo
  echo "LIKELY UI FILES"
  find . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './.next' -prune -o \
    -path './dist' -prune -o \
    -path './build' -prune -o \
    -type f \( \
      -name '*.tsx' -o \
      -name '*.ts' -o \
      -name '*.jsx' -o \
      -name '*.js' \
    \) -print | sort | grep -E '/(app|src|components|ui|dashboard)/' || true
  echo
  echo "GOVERNANCE / TRACE / APPROVAL / EXECUTION REFERENCES"
  grep -RInE \
    'governance|trace|approval|execute|execution|reporting|intake|ruleId|evaluationResult|NO_MATCH|MATCH' \
    app src components . 2>/dev/null | \
    grep -vE 'node_modules|\.next|dist|build' | sort || true
  echo
  echo "NEXT.JS PAGE / LAYOUT / ROUTE CANDIDATES"
  find app src . \
    -path './.git' -prune -o \
    -path './node_modules' -prune -o \
    -path './.next' -prune -o \
    -path './dist' -prune -o \
    -path './build' -prune -o \
    -type f \( \
      -name 'page.tsx' -o \
      -name 'layout.tsx' -o \
      -name 'route.ts' \
    \) -print 2>/dev/null | sort || true
  echo
  echo "CANDIDATE RENDER SURFACES (FIRST PASS)"
  grep -RIlE \
    'governance|trace|approval|execution|reporting|intake' \
    app src components . 2>/dev/null | \
    grep -vE 'node_modules|\.next|dist|build|docs/' | sort || true
  echo
  echo "BACKEND MUTATION CHECK"
  echo
  echo "This step is inventory-only."
  echo "No backend mutation is performed by this script."
} > "$OUT"

echo "Wrote $OUT"
