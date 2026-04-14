#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="app/demo-runtime/page.tsx"
OUT="docs/phase486_step9_selected_ui_host_inspection.txt"

{
  echo "PHASE 486 — STEP 9"
  echo "SELECTED UI HOST INSPECTION"
  echo
  echo "OBJECTIVE"
  echo
  echo "Inspect the selected UI host and define the safest insertion boundary"
  echo "for governance trace rendering without backend mutation."
  echo
  echo "TARGET FILE"
  echo "$TARGET"
  echo
  echo "EXISTENCE CHECK"
  if [ -f "$TARGET" ]; then
    echo "FOUND"
  else
    echo "MISSING"
    exit 1
  fi
  echo
  echo "FILE METADATA"
  ls -l "$TARGET"
  echo
  echo "LINE COUNT"
  wc -l "$TARGET"
  echo
  echo "FULL FILE WITH LINE NUMBERS"
  nl -ba "$TARGET"
  echo
  echo "JSX RETURN SIGNALS"
  grep -nE 'return \(|return <|<main|<section|<div|<article|<Fragment|<>' "$TARGET" || true
  echo
  echo "EXPORT SIGNALS"
  grep -nE '^export default|function |const .*=' "$TARGET" || true
  echo
  echo "HOOK / STATE / EFFECT SIGNALS"
  grep -nE 'useState|useEffect|useMemo|useCallback|useRef' "$TARGET" || true
  echo
  echo "DATA SOURCE SIGNALS"
  grep -nE 'fetch|await |async |props|params|searchParams|demo-runtime|governance|trace|approval|execution|report' "$TARGET" || true
  echo
  echo "INITIAL INSERTION BOUNDARY RULE"
  echo
  echo "Choose the nearest existing passive render block inside the page component."
  echo "Do not create new data acquisition logic."
  echo "Do not alter existing control flow."
  echo "Do not move backend logic into UI."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
