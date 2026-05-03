#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="${1:-}"
NOTE="${2:-}"
OUT="docs/phase471_7_static_shell_result.txt"

if [ -z "$RESULT" ]; then
  echo "Usage:"
  echo "  ./scripts/phase471_8_record_static_shell_result.sh STATIC_SHELL_STABLE"
  echo "  ./scripts/phase471_8_record_static_shell_result.sh STATIC_SHELL_STILL_UNRESPONSIVE \"optional note\""
  echo "  ./scripts/phase471_8_record_static_shell_result.sh WHITE_SCREEN_RETURNED \"optional note\""
  exit 1
fi

case "$RESULT" in
  STATIC_SHELL_STABLE|STATIC_SHELL_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $RESULT"
    exit 1
    ;;
esac

mkdir -p docs

cat > "$OUT" <<EOT
PHASE 471.7 — STATIC SHELL RESULT
=================================

RESULT:
$RESULT

OPTIONAL_NOTE:
$NOTE
EOT

echo "Wrote $OUT"
sed -n '1,120p' "$OUT"
