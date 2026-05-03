#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_8_observe_minimal_probe_stability.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 473.8 — OBSERVE MINIMAL PROBE STABILITY
=============================================

STATUS
- Server is running
- Container public sync is fixed
- /minimal_probe.html is serving correctly

DO THIS NOW
1. Open:
   http://localhost:8080/minimal_probe.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- MINIMAL_PROBE_STABLE
- MINIMAL_PROBE_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/minimal_probe.html" || true
fi
