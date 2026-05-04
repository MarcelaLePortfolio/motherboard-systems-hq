#!/usr/bin/env bash
set -euo pipefail

echo "Seeding live runtime proof task..."

curl -sS -X POST http://localhost:3000/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{
    "task_id": "phase631-live-runtime-proof",
    "title": "Phase 631 Live Runtime Proof",
    "kind": "verification",
    "payload": {
      "goal": "Verify full execution + guidance path on live task",
      "notes": "This should flow through worker → completion → guidance rendering → inspector"
    }
  }' | jq .

echo
echo "Waiting for worker to process..."
sleep 3

echo
echo "Verifying /api/tasks..."
curl -sS http://localhost:3000/api/tasks | jq .

echo
echo "Done. Now verify in UI:"
echo "- Task appears in dashboard"
echo "- Click task row"
echo "- Execution Inspector shows guidance"
echo "- No SSE errors"
