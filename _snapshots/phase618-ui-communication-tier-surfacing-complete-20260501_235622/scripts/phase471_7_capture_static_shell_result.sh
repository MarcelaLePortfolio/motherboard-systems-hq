#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase471_7_static_shell_result.txt"
mkdir -p docs

cat > "$OUT" <<'EOT'
PHASE 471.7 — STATIC SHELL RESULT
=================================

Replace the placeholder below with EXACTLY ONE of:

- STATIC_SHELL_STABLE
- STATIC_SHELL_STILL_UNRESPONSIVE
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
