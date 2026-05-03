#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase472_3_bare_html_observation_step.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 472.3 — BARE HTML OBSERVATION STEP
========================================

STATUS
- bundle.js boot is removed
- external stylesheet links are removed
- current page should be bare HTML only

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- BARE_HTML_STABLE
- BARE_HTML_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
