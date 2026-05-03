#!/bin/bash
set -euo pipefail

INPUT="PHASE617_EXECUTION_COMMUNICATION_TIER_CHERRYPICK.txt"
OUT="PHASE617_SYSTEMTRACE_LINES.txt"

grep -nE "systemTrace" "$INPUT" > "$OUT" || true

echo "Extracted systemTrace lines → $OUT"
