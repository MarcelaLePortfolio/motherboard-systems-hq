#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-}"
NOTE="${2:-}"
OUT="docs/phase472_4_bare_html_result.txt"

if [ -z "$RESULT" ]; then
  echo "Usage:"
  echo "  ./scripts/phase472_5_record_bare_html_result.sh BARE_HTML_STABLE"
  echo "  ./scripts/phase472_5_record_bare_html_result.sh BARE_HTML_STILL_UNRESPONSIVE \"optional note\""
  echo "  ./scripts/phase472_5_record_bare_html_result.sh WHITE_SCREEN_RETURNED \"optional note\""
  exit 1
fi

case "$RESULT" in
  BARE_HTML_STABLE|BARE_HTML_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $RESULT"
    exit 1
    ;;
esac

mkdir -p docs

cat > "$OUT" <<EOT
PHASE 472.4 — BARE HTML RESULT
==============================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"
