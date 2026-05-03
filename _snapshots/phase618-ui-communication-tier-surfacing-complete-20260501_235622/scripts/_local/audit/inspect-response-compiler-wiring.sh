#!/bin/bash
set -e

echo "🔍 Inspecting response compiler contract and UI mapping docs..."

echo ""
echo "=== PHASE604_COMMUNICATION_CONTRACT_DEFINITION ==="
sed -n '1,140p' PHASE604_COMMUNICATION_CONTRACT_DEFINITION.txt || true

echo ""
echo "=== PHASE605_RESPONSE_COMPILER_DESIGN_PLAN ==="
sed -n '1,120p' PHASE605_RESPONSE_COMPILER_DESIGN_PLAN.txt || true

echo ""
echo "=== PHASE607_RESPONSE_COMPILER_STABLE ==="
sed -n '1,120p' PHASE607_RESPONSE_COMPILER_STABLE.txt || true

echo ""
echo "=== PHASE609_PRESENTATION_AUTHORITY_PLAN ==="
sed -n '1,120p' PHASE609_PRESENTATION_AUTHORITY_PLAN.txt || true

echo ""
echo "=== PHASE610_UI_SURFACE_INSPECTION_PLAN ==="
sed -n '1,120p' PHASE610_UI_SURFACE_INSPECTION_PLAN.txt || true

echo ""
echo "=== SEARCH: compiler implementation ==="
grep -RIn "outcome\|explanation\|systemTrace\|responseCompiler\|compileResponse" server app lib src . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=_snapshots || true

echo ""
echo "✅ Inspection complete. Use these exact fields for the Inspector patch."
