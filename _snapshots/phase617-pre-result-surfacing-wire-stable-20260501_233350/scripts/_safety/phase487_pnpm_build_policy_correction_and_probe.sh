#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 487 PNPM BUILD POLICY CORRECTION + PROBE ==="

echo
echo "=== Step 1: snapshot current pnpm-workspace.yaml ==="
cp pnpm-workspace.yaml pnpm-workspace.yaml.bak_phase487
echo "--- current pnpm-workspace.yaml ---"
sed -n '1,120p' pnpm-workspace.yaml

echo
echo "=== Step 2: correct project build policy for better-sqlite3 ==="
cat > pnpm-workspace.yaml << 'INNER_EOF'
allowBuilds:
  better-sqlite3: true
INNER_EOF

echo "--- corrected pnpm-workspace.yaml ---"
sed -n '1,120p' pnpm-workspace.yaml

echo
echo "=== Step 3: rebuild better-sqlite3 under corrected policy ==="
pnpm rebuild better-sqlite3

echo
echo "=== Step 4: verify binding file existence (bounded) ==="
find node_modules -path '*better_sqlite3.node' | head -20 || true

echo
echo "=== Step 5: rerun bounded server.ts live-start probe ==="
bash scripts/_safety/phase487_server_ts_live_start_probe.sh

echo
echo "=== Step 6: tail live-start probe output ==="
tail -60 docs/phase487_server_ts_live_start_probe_output.txt || true
