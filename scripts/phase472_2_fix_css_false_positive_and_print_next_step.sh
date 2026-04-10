#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase472_2_fix_css_false_positive_and_print_next_step.txt"
HTML="public/dashboard.html"

mkdir -p docs

{
  echo "PHASE 472.2 — FIX CSS FALSE POSITIVE AND PRINT NEXT STEP"
  echo "======================================================="
  echo

  echo "STEP 1 — Show why phase472.1 misclassified"
  echo "The previous check matched stylesheet text inside neutralization comments."
  echo
  rg -n '<link[^>]*rel="stylesheet"|phase472\.1 temporary neutralization' "$HTML" || true
  echo

  echo "STEP 2 — Verify actual stylesheet tag absence"
  if rg -q '^[[:space:]]*<link[^>]*rel="stylesheet"' "$HTML"; then
    echo "ACTUAL_STYLESHEET_TAG_PRESENT"
  else
    echo "ACTUAL_STYLESHEET_TAG_ABSENT"
  fi
  echo

  echo "STEP 3 — Corrected classification"
  if rg -q '^[[:space:]]*<link[^>]*rel="stylesheet"' "$HTML"; then
    echo "CLASSIFICATION: STYLESHEET_LINKS_STILL_PRESENT"
  else
    echo "CLASSIFICATION: BARE_HTML_READY_FOR_BROWSER_FREEZE_ISOLATION"
  fi
  echo

  echo "STEP 4 — Browser observation instruction"
  echo "Open: http://localhost:8080/dashboard.html"
  echo "Let it sit for 30–60 seconds."
  echo "Then report exactly one of:"
  echo "- BARE_HTML_STABLE"
  echo "- BARE_HTML_STILL_UNRESPONSIVE"
  echo "- WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
