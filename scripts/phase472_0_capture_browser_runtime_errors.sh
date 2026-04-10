#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase472_0_browser_runtime_capture.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 472.0 — BROWSER RUNTIME ERROR CAPTURE
===========================================

CONCLUSION FROM 471.x
- Static HTML shell is STILL unresponsive
- Freeze is NOT caused by:
  • operator guidance probe
  • task-events surface
  • bundle.js boot

THIS INDICATES:
- Issue is likely browser-level:
  • corrupted DOM
  • blocking CSS/layout
  • malformed HTML
  • or cached script interference

DO THIS EXACTLY

STEP 1 — HARD REFRESH (CRITICAL)
- Open: http://localhost:8080/dashboard.html
- Press: CMD + SHIFT + R

STEP 2 — OPEN DEVTOOLS
- Right click → Inspect
- Go to CONSOLE tab

STEP 3 — WATCH FOR 10–20 SECONDS

LOOK FOR:
- red errors
- "Uncaught" anything
- "Failed to load"
- "SyntaxError"
- "TypeError"
- repeated logs

STEP 4 — COPY EVERYTHING YOU SEE IN CONSOLE

RETURN TO CHATGPT WITH:
- Full console output (copy/paste)
- OR type: NO_ERRORS_VISIBLE

DO NOT INTERPRET
DO NOT FILTER
JUST COPY RAW OUTPUT
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
