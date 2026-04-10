#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase474_0_observe_styled_shell_result.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 474.0 — OBSERVE STYLED SHELL RESULT
=========================================

STATUS
- Styles are restored
- bundle.js is still disabled
- current page is the styled shell only

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- STYLED_SHELL_STABLE
- STYLED_SHELL_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
