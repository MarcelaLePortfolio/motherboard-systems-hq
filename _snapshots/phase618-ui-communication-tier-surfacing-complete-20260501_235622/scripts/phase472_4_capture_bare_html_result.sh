#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase472_4_bare_html_result.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 472.4 — BARE HTML RESULT
==============================

Replace PLACE_RESULT_HERE with EXACTLY ONE of:
- BARE_HTML_STABLE
- BARE_HTML_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED

RESULT:
PLACE_RESULT_HERE

OPTIONAL_NOTE:
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"

if command -v code >/dev/null 2>&1; then
  code "$OUT"
elif command -v open >/dev/null 2>&1; then
  open -a TextEdit "$OUT" || true
fi

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi
