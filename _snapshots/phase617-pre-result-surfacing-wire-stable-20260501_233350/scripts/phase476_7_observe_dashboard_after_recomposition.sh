#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase476_7_observe_dashboard_after_recomposition.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 476.7 — OBSERVE DASHBOARD AFTER RECOMPOSITION
===================================================

STATUS
- dashboard.html now matches the recomposed stable probe structure
- dashboard route is serving the recomposed structure directly

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- DASHBOARD_NOW_STABLE
- DASHBOARD_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
