
#!/bin/bash

set -euo pipefail

echo "=== Phase 733 Style Intent Payload Verification ==="

echo

echo "Paste the task_id for the latest Artifact Garden style test, then press Enter:"

read -r TASK_ID

OUTPUT="PHASE733_STYLE_INTENT_PAYLOAD_${TASK_ID}.json"

curl -s "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" > "$OUTPUT"

echo

echo "=== Saved payload ==="

echo "$OUTPUT"

echo

echo "=== style_intent search ==="

grep -n "style_intent\|cream\|blush\|plum\|sage\|honey\|lavender" "$OUTPUT" || true

echo

echo "=== payload preview first 80 lines ==="

sed -n '1,80p' "$OUTPUT"

