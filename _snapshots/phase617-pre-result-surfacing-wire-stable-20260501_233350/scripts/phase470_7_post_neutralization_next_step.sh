#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase470_7_post_neutralization_next_step.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 470.7 — POST-NEUTRALIZATION NEXT STEP
===========================================

STATUS
- operatorGuidance.sse.js has been neutralized from dashboard.html
- dashboard.html returns 200 on host port 8080
- bundle.js returns 200 on host port 8080
- operator-guidance probe is no longer being requested by the page
- current corridor: verify whether freeze/unresponsive behavior is relieved

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let the page sit for 60–90 seconds.

3. Check only these observable behaviors:
   - Does the page stay clickable?
   - Does scrolling still work?
   - Do tabs/buttons still respond?
   - Does it turn white again?
   - Does it become visually frozen?

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- STABLE_AFTER_NEUTRALIZATION
- STILL_FREEZES
- WHITE_SCREEN_RETURNED

OPTIONAL NOTE
- mention roughly how many seconds passed before failure if it still freezes
EOT

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
