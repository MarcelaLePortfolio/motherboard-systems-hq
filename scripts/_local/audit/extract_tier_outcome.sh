#!/bin/bash
set -euo pipefail

INPUT="PHASE617_EXECUTION_COMMUNICATION_TIER_CHERRYPICK.txt"
OUT="PHASE617_OUTCOME_LINES.txt"

grep -nE "outcome_preview|outcome:" "$INPUT" > "$OUT" || true

echo "Extracted outcome lines → $OUT"
