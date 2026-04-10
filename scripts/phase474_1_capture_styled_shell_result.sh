#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase474_1_styled_shell_result.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 474.1 — STYLED SHELL RESULT
=================================

Replace PLACE_RESULT_HERE with EXACTLY ONE of:
- STYLED_SHELL_STABLE
- STYLED_SHELL_STILL_UNRESPONSIVE
- WHITE_SCREEN_RETURNED

RESULT:
PLACE_RESULT_HERE

OPTIONAL_NOTE:
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"

if command -v open >/dev/null 2>&1; then
  open "http://localhost:8080/dashboard.html" || true
fi

if command -v code >/dev/null 2>&1; then
  code "$OUT"
elif command -v open >/dev/null 2>&1; then
  open -a TextEdit "$OUT" || true
fi
