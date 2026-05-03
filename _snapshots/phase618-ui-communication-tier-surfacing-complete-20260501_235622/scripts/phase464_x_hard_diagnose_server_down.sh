#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_hard_diagnose_server_down.txt"

mkdir -p docs

echo "PHASE 464.X — HARD DIAGNOSE: SERVER DOWN" > "$OUT"
echo "========================================" >> "$OUT"
echo >> "$OUT"

echo "STEP 1 — Docker containers" >> "$OUT"
docker compose ps >> "$OUT" 2>&1 || echo "docker unavailable" >> "$OUT"
echo >> "$OUT"

echo "STEP 2 — Port 3000 listeners" >> "$OUT"
lsof -i :3000 >> "$OUT" 2>&1 || echo "no process on 3000" >> "$OUT"
echo >> "$OUT"

echo "STEP 3 — Recent container logs (dashboard)" >> "$OUT"
docker compose logs --tail=100 >> "$OUT" 2>&1 || echo "no logs available" >> "$OUT"
echo >> "$OUT"

echo "STEP 4 — Attempt direct node process check" >> "$OUT"
ps aux | rg node >> "$OUT" 2>&1 || echo "no node processes" >> "$OUT"
echo >> "$OUT"

echo "STEP 5 — Curl root and health" >> "$OUT"
echo "--- ROOT ---" >> "$OUT"
curl -s --max-time 2 http://localhost:3000 >> "$OUT" 2>&1 || echo "root failed" >> "$OUT"
echo >> "$OUT"
echo "--- HEALTH ---" >> "$OUT"
curl -s --max-time 2 http://localhost:3000/api/diagnostics/system-health >> "$OUT" 2>&1 || echo "health failed" >> "$OUT"
echo >> "$OUT"

echo "DIAGNOSIS COMPLETE" >> "$OUT"

echo "Wrote $OUT"

