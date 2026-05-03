#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase476_9_observe_attribute_reintroduced_dashboard.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 476.9 — OBSERVE ATTRIBUTE-REINTRODUCED DASHBOARD
======================================================

STATUS
- dashboard route is serving the stable recomposed structure
- original body attributes have been restored
- no structural reintroduction has occurred yet

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- ATTRIBUTES_REINTRO_STABLE
- ATTRIBUTES_REINTRO_BREAKS
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
