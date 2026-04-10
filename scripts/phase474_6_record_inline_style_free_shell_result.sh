#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-}"
NOTE="${2:-}"
OUT="docs/phase474_6_inline_style_free_shell_result.txt"

if [ -z "$RESULT" ]; then
  echo "Usage:"
  echo '  ./scripts/phase474_6_record_inline_style_free_shell_result.sh INLINE_STYLE_FREE_SHELL_STABLE'
  echo '  ./scripts/phase474_6_record_inline_style_free_shell_result.sh INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE "optional note"'
  echo '  ./scripts/phase474_6_record_inline_style_free_shell_result.sh WHITE_SCREEN_RETURNED "optional note"'
  exit 1
fi

case "$RESULT" in
  INLINE_STYLE_FREE_SHELL_STABLE|INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $RESULT"
    exit 1
    ;;
esac

mkdir -p docs

cat > "$OUT" <<EOT
PHASE 474.6 — INLINE-STYLE-FREE SHELL RESULT
============================================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"
