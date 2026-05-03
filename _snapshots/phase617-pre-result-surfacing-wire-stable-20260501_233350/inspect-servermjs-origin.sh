#!/bin/bash
set -euo pipefail

echo "🔍 Inspecting how server.mjs is produced..."
echo

echo "=== 1) File metadata ==="
ls -l server.mjs 2>/dev/null || true
echo
stat server.mjs 2>/dev/null || true
echo

echo "=== 2) First 120 lines of server.mjs ==="
sed -n '1,120p' server.mjs 2>/dev/null || true
echo

echo "=== 3) Search repo for direct references to server.mjs ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E '\bserver\.mjs\b|node server\.mjs|COPY .*server\.mjs|server\.mjs:' . || true
echo

echo "=== 4) Search for likely build/emission patterns ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'esbuild|rollup|tsup|swc|babel|webpack|outfile.*server\.mjs|outdir|build-dashboard|bundle|emit.*server|writeFile.*server\.mjs|copyFile.*server\.mjs' . || true
echo

echo "=== 5) Dockerfile / compose references ==="
for f in Dockerfile docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [ -f "$f" ]; then
    echo "📄 FILE: $f"
    echo "------------------------------------------------"
    sed -n '1,220p' "$f"
    echo
  fi
done

echo "=== 6) package.json ==="
sed -n '1,220p' package.json 2>/dev/null || true
echo

echo "=== 7) Likely helper/build scripts ==="
for f in scripts/build-dashboard-bundle.js scripts/_local/dev/skip-ui-build.js scripts/_local/handlers/buildUI.ts; do
  if [ -f "$f" ]; then
    echo "📄 FILE: $f"
    echo "------------------------------------------------"
    sed -n '1,220p' "$f"
    echo
  fi
done

echo "✅ Inspection complete."
echo "Paste back any evidence showing whether server.mjs is hand-maintained or generated."
