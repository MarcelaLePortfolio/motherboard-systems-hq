#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase477_5_observe_inline_script_free_dashboard.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 477.5 — OBSERVE INLINE-SCRIPT-FREE DASHBOARD
==================================================

STATUS
- dashboard route is serving without inline script blocks
- inline scripts have been neutralized
- src-based scripts still remain
- this is the next clean isolation checkpoint

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- INLINE_SCRIPT_FREE_STABLE
- INLINE_SCRIPT_FREE_STILL_LOADING
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
