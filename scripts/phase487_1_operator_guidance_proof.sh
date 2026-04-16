#!/usr/bin/env bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_guidance_proof.txt"
TIMESTAMP="$(date)"

echo "PHASE 487 — OPERATOR GUIDANCE PROOF" > "$OUTPUT"
echo "Timestamp: $TIMESTAMP" >> "$OUTPUT"
echo "----------------------------------------" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "[1] LOCATING GUIDANCE SOURCE FILES" >> "$OUTPUT"
grep -Rni "Operator Guidance" . >> "$OUTPUT" || true

echo "" >> "$OUTPUT"
echo "[2] LOCATING GUIDANCE SIGNAL EMISSIONS" >> "$OUTPUT"
grep -Rni "SYSTEM_HEALTH" . >> "$OUTPUT" || true

echo "" >> "$OUTPUT"
echo "[3] LOCATING INTERVAL / LOOP PATTERNS" >> "$OUTPUT"
grep -Rni "setInterval" . >> "$OUTPUT" || true
grep -Rni "setTimeout" . >> "$OUTPUT" || true

echo "" >> "$OUTPUT"
echo "[4] LOCATING API / STREAM SOURCES" >> "$OUTPUT"
grep -Rni "/api" . >> "$OUTPUT" || true

echo "" >> "$OUTPUT"
echo "[5] RAW DASHBOARD RESPONSE SAMPLE" >> "$OUTPUT"
curl -s http://localhost:8080 >> "$OUTPUT" || echo "Dashboard not reachable" >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "PROOF COMPLETE — NO MUTATION PERFORMED" >> "$OUTPUT"

echo "Proof written to $OUTPUT"
