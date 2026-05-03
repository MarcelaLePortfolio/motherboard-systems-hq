#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase478_2_observe_phase60_live_clock_reintroduction.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 478.2 — OBSERVE PHASE60 LIVE CLOCK REINTRODUCTION
=======================================================

STATUS
- The original structural layout is restored
- All scripts were disabled, then only js/phase60_live_clock.js was reintroduced
- This is the first controlled single-script restoration checkpoint

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Check:
   - Does it remain stable?
   - Does anything visibly improve?
   - Does anything regress?

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- PHASE60_SCRIPT_STABLE
- PHASE60_SCRIPT_BREAKS
- WHITE_SCREEN_RETURNED

OPTIONAL_NOTE
- brief note on whether the clock updated or whether the layout changed at all
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
