#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase471_6_waiting_for_static_shell_result.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 471.6 — WAITING FOR STATIC SHELL RESULT
=============================================

YOU ARE AT THE DECISION POINT.

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Wait 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- STATIC_SHELL_STABLE
- STATIC_SHELL_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
