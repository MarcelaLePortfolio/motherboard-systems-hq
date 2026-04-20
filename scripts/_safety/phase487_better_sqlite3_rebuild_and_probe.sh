#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 better-sqlite3 NATIVE REBUILD + PROBE ==="

echo
echo "=== Step 1: rebuild better-sqlite3 native binding ==="
pnpm rebuild better-sqlite3

echo
echo "=== Step 2: rerun bounded server.ts live-start probe ==="
bash scripts/_safety/phase487_server_ts_live_start_probe.sh

echo
echo "=== Step 3: tail live-start probe output ==="
tail -60 docs/phase487_server_ts_live_start_probe_output.txt || true
