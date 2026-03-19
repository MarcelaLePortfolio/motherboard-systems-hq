#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE="PHASE88_8_SYSTEM_HEALTH_JS_ROUTE_PAYLOAD.json"
EVIDENCE_FILE="PHASE88_8_SYSTEM_HEALTH_JS_ROUTE_PAYLOAD_EVIDENCE.txt"

npx tsx scripts/phase88_8_capture_system_health_js_route_payload.ts > "$OUTPUT_FILE"

{
  echo "PHASE 88.8 SYSTEM HEALTH JS ROUTE PAYLOAD EVIDENCE"
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Branch: $(git rev-parse --abbrev-ref HEAD)"
  echo "Commit: $(git rev-parse HEAD)"
  echo "Payload File: $OUTPUT_FILE"
  echo "────────────────────────────────"
  cat "$OUTPUT_FILE"
} | tee "$EVIDENCE_FILE"
