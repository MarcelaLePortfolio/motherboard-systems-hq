#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_targeted_log_focus.txt"

mkdir -p docs

echo "PHASE 464.X — TARGETED FAILURE ISOLATION" > "$OUT"
echo "========================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Filter dashboard errors only" >> "$OUT"
docker compose logs --tail=200 2>&1 | rg -i "error|cannot find module|failed|exception" >> "$OUT" || echo "no critical errors found" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Check for missing dependencies explicitly" >> "$OUT"
docker compose logs 2>&1 | rg -i "Cannot find module" >> "$OUT" || echo "no missing module errors" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Confirm server entrypoint execution" >> "$OUT"
docker compose logs 2>&1 | rg -i "listening|server started|app running" >> "$OUT" || echo "no server start confirmation found" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Extract last crash signature (if any)" >> "$OUT"
docker compose logs --tail=50 >> "$OUT" 2>&1
echo >> "$OUT"

echo "STEP 5 — Quick dependency presence check inside container" >> "$OUT"
CONTAINER_ID=$(docker compose ps -q | head -n 1 || echo "")
if [ -n "$CONTAINER_ID" ]; then
  docker exec "$CONTAINER_ID" ls node_modules >> "$OUT" 2>&1 || echo "cannot inspect node_modules" >> "$OUT"
else
  echo "no running container to inspect" >> "$OUT"
fi
echo >> "$OUT"

echo "DIAGNOSIS FOCUS COMPLETE" >> "$OUT"

echo "Wrote $OUT"

