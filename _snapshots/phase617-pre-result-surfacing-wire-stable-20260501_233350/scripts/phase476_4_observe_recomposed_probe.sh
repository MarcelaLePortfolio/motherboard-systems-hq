#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase476_4_observe_recomposed_probe.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 476.4 — OBSERVE RECOMPOSED PROBE
======================================

STATUS
- Q1 is stable
- Q2 is stable
- Q3 is stable
- Q4 is stable
- recomposed full-body probe from stable quarters is now serving

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- RECOMPOSED_PROBE_STABLE
- RECOMPOSED_PROBE_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html" || true
fi
