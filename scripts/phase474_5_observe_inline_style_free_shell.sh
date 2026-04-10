#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase474_5_observe_inline_style_free_shell.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 474.5 — OBSERVE INLINE-STYLE-FREE SHELL
=============================================

STATUS
- bundle.js is still disabled
- local CSS is removed
- inline <style> blocks are removed
- only Tailwind remains

DO THIS NOW
1. Open:
   http://localhost:8080/dashboard.html

2. Let it sit for 30–60 seconds.

3. Try:
   - scroll once
   - click once anywhere harmless

RETURN TO CHATGPT WITH EXACTLY ONE OF THESE
- INLINE_STYLE_FREE_SHELL_STABLE
- INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED
EOT

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
