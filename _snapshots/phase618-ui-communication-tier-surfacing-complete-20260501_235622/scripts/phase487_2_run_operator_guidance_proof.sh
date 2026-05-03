#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

PROOF_SCRIPT="scripts/phase487_1_operator_guidance_proof.sh"
OUTPUT="docs/phase487_guidance_proof.txt"
SUMMARY="docs/phase487_guidance_proof_summary.txt"

if [ ! -x "$PROOF_SCRIPT" ]; then
  echo "Missing executable proof script: $PROOF_SCRIPT" >&2
  exit 1
fi

"$PROOF_SCRIPT"

{
  echo "PHASE 487 — OPERATOR GUIDANCE PROOF SUMMARY"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[A] OPERATOR GUIDANCE REFERENCES"
  grep -n "Operator Guidance" "$OUTPUT" || true
  echo

  echo "[B] SYSTEM_HEALTH REFERENCES"
  grep -n "SYSTEM_HEALTH" "$OUTPUT" || true
  echo

  echo "[C] INTERVAL / LOOP REFERENCES"
  grep -n "setInterval" "$OUTPUT" || true
  grep -n "setTimeout" "$OUTPUT" || true
  echo

  echo "[D] API REFERENCES"
  grep -n "/api" "$OUTPUT" || true
  echo

  echo "[E] FINAL 60 LINES OF RAW PROOF"
  tail -n 60 "$OUTPUT" || true
  echo

  echo "SUMMARY COMPLETE"
} > "$SUMMARY"

echo "Generated:"
echo "  - $OUTPUT"
echo "  - $SUMMARY"
