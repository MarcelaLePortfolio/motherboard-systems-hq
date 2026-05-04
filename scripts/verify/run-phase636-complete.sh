#!/bin/bash
set -e

echo "PHASE 636 — COMPLETION SEQUENCE START"

echo "Step 1: Rebuild runtime"
docker compose up -d --build

echo "Step 2: Wait for server"
sleep 8

echo "Step 3: Validate SSE stream"
bash scripts/verify/test-subsystem-sse.sh

echo "Step 4: Open UI (should live-update via SSE)"
bash scripts/verify/test-subsystem-ui.sh

echo "Step 5: Tag completion"
git tag -a phase636-complete -m "Phase 636 complete: subsystem SSE streaming + UI live updates verified"
git push origin phase636-complete

echo "PHASE 636 COMPLETE — SSE streaming active and UI verified."
