#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase477_3_observe_dashboard_after_probe_banner_removal.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 477.3 — OBSERVE DASHBOARD AFTER PROBE BANNER REMOVAL
==========================================================

STATUS
- dashboard route is serving the stable recomposed structure
- original body attributes are restored
- probe banner artifacts have been removed

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- BANNER_REMOVAL_STABLE
- BANNER_REMOVAL_BREAKS
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
