#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase478_8_force_hard_reload_and_verify_css_application.txt"
mkdir -p docs

cat > "$OUT" << 'EOT'
PHASE 478.8 — FORCE HARD RELOAD + VERIFY CSS APPLICATION
========================================================

CRITICAL INSIGHT
- CSS has now been reintroduced (dashboard.css + dashboard-reflections.css)
- BUT the dashboard may still appear unchanged due to:
  • browser caching
  • stale asset versions
  • Docker layer caching
  • missing CSS file resolution

THIS STEP IS NOT ABOUT CHANGING CODE
This is about VERIFYING whether CSS is ACTUALLY being applied.

DO THIS EXACTLY

1. HARD REFRESH (REQUIRED)
   Mac:
   - Hold SHIFT + click refresh
   OR
   - CMD + SHIFT + R

2. OPEN DEVTOOLS
   - Right click → Inspect
   - Go to "Network" tab
   - Check:
     ☐ "Disable cache" (IMPORTANT)

3. RELOAD AGAIN WITH DEVTOOLS OPEN

4. VERIFY CSS FILES LOADED
   In Network tab, filter by "CSS"

   You MUST see:
   - css/dashboard.css
   - css/dashboard-reflections.css

   If NOT present:
   → CSS is NOT being served (root issue)

5. CLICK EACH CSS FILE
   Confirm:
   - Status = 200 (NOT 404)
   - Content is NOT empty

6. CHECK IF CSS IS APPLIED
   Go to "Elements" tab
   Click a broken UI element

   Look for:
   - styles from dashboard.css
   - styles from dashboard-reflections.css

RETURN EXACTLY ONE:

- CSS_NOT_LOADING
- CSS_LOADING_NOT_APPLYING
- CSS_APPLYING_BUT_LAYOUT_STILL_WRONG

OPTIONAL_NOTE
- Example:
  "CSS files 404"
  "CSS loaded but no styles applied"
  "Styles applied but layout still broken"
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
