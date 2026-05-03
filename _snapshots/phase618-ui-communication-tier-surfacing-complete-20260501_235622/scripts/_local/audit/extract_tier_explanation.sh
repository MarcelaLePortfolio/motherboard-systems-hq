#!/bin/bash
set -euo pipefail

INPUT="PHASE617_EXECUTION_COMMUNICATION_TIER_CHERRYPICK.txt"
OUT="PHASE617_EXPLANATION_LINES.txt"

grep -nE "explanation_preview|explanation:" "$INPUT" > "$OUT" || true

echo "Extracted explanation lines → $OUT"
