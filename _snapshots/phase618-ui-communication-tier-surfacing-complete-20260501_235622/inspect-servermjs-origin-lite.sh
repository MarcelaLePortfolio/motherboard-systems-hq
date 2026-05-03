#!/bin/bash
set -euo pipefail

echo "🔍 Inspecting server.mjs origin (lite mode)..."
echo

echo "=== 1) File header (first 60 lines) ==="
sed -n '1,60p' server.mjs 2>/dev/null || true
echo

echo "=== 2) Look for build fingerprints ==="
grep -nE 'esbuild|rollup|tsup|swc|babel|webpack|generated|bundle|outfile|outdir' server.mjs || true
echo

echo "=== 3) Who references server.mjs ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git 'server.mjs' . || true
echo

echo "=== 4) Dockerfile (first 120 lines) ==="
if [ -f Dockerfile ]; then
  sed -n '1,120p' Dockerfile
fi
echo

echo "=== 5) docker-compose (first 120 lines) ==="
for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [ -f "$f" ]; then
    sed -n '1,120p' "$f"
  fi
done
echo

echo "=== 6) package.json scripts ==="
sed -n '1,120p' package.json 2>/dev/null || true
echo

echo "✅ Done. We only need to see if server.mjs is generated or not."
